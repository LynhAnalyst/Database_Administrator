--1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó
create proc sp1 @br_id varchar(10), @br_name nvarchar(100) out
as
begin
	select @br_name = BR_name from Branch where BR_id = @br_id
end

declare @kq nvarchar(100)
exec sp1 'VB001', @kq out
print @kq
go

--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.
create proc sp2 @cus_id varchar(10), @cus_name nvarchar(50) out, @cus_ad nvarchar(50) out, @cus_phone varchar(15) out
as 
begin
	select @cus_name = Cust_name, @cus_ad = Cust_ad, @cus_phone = Cust_phone from customer
	where @cus_id = Cust_id
end

declare @ten nvarchar(50), @diachi nvarchar(100), @sdt varchar(12)
exec sp2 '000001', @ten output, @diachi output, @sdt output
print @ten
print @diachi
print @sdt
go

--3. In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó.
create function f3 (@br_id varchar(10))
returns table
as
	return select Cust_id, Cust_name, Cust_phone, Cust_ad from customer
	where Br_id = @br_id

select * from f3 ('VT009')
go

/*4. Kiểm tra một khách hàng nào đó tồn tại trong hệ thống CSDL của ngân hàng chưa 
Nếu biết: Họ tên, số điện thoại. Đã tồn tại trả về 1, ngược lại trả về 0*/
create function f4 (@name nvarchar(100), @phone varchar(15))
returns varchar(1)
as 
begin
	declare @kq int, @dem int
	set @dem = (select count(Cust_id) from customer where @name = Cust_name and @phone = Cust_phone)
	if @dem > 0 
	begin
		set @kq = 1
	end
	else
	begin
		set @kq = 0
	end
	return @kq
end

select dbo.f4 (N'Hà Công Lực', '01283388103')
go

/*5. Cập nhật số tiền trong tài khoản nếu biết mã số tài khoản và số tiền mới.
Thành công trả về 1, thất bại trả về 0*/
create proc sp5 @matk varchar(15), @tienmoi varchar(15), @trave varchar(1) out
as 
begin
	update account
	set ac_balance = @tienmoi
	where Ac_no = @matk
	if @@ROWCOUNT > 0
		set @trave = 1
	else
		set @trave = 0
end

declare @kq varchar(1)
exec sp5 '1000000001', '500000', @kq output
print @kq
go

--6. Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0
create proc sp6 @id varchar(10), @ad nvarchar(100), @trave varchar(1) out
as 
begin
	update customer
	set @ad = Cust_ad
	where @id = Cust_id

	if @@ROWCOUNT > 0
	begin 
		set @trave = 1
	end
	else 
	begin
		set @trave = 0
	end
end

declare @kq int
exec sp6 '000005',N'Hương Chữ, Hương Trà, Huế', @kq output
print @kq 
go

--7. Trả về số tiền có trong tài khoản nếu biết mã tài khoản
create proc sp7 @id varchar(10), @tien int out
as
begin
	select @tien = ac_balance from account
	where @id = Ac_no
end

declare @kq int
exec sp7 '1000000001', @kq output
print @kq
go

--8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh
create proc sp8 @macn varchar(15), @sokh int out, @sotien int out
as
begin
	select @sotien = sum(ac_balance), @sokh = count(customer.Cust_id)
	from Branch join customer on Branch.BR_id = customer.Br_id
	join account on customer.Cust_id = account.cust_id
	where Branch.Br_id = @macn
end

declare @sokh int, @tongtien int
exec sp5 'VT009', @sokh out, @tongtien out
print @sokh
print @tongtien
go

/*9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. Giao dịch bất thường: 
Giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am tới 3am */
create proc sp9 @magd varchar(10), @trave nvarchar(50) out
as
begin 
	declare @loaigd int, @thoigian varchar(5)
	select @loaigd = t_type, @thoigian = t_time
	from transactions 
	where @magd = t_id

	if @loaigd = 1 and @thoigian not between '07:30' and '11:30'
				   or @thoigian not between '13:30' and '16:00'
		set @trave = N'Giao dịch bất thường'
	else if @loaigd = 0 and @thoigian between '00:00' and '03:00'
		set @trave = N'Giao dịch bất thường'
	else
		set @trave = N'Giao dịch bình thường'
end

declare @trave nvarchar(50)
exec sp9 '0000000204', @trave output
print @trave
go

--10. Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: MAX(mã giao dịch đang có) + 1
create proc sp10 @mamoi varchar(11) out
as 
begin
	declare @mamax varchar(15), @len varchar(15)
	set @mamax = (select max(t_id) from transactions)
	set @mamoi = @mamax + 1
	set @len = (select top 1 len(t_id) from transactions)
	set @mamoi = REPLICATE('0', @len - len(@mamoi)) + @mamoi
end

declare @mamoi varchar(11) 
exec sp10 @mamoi out
print @mamoi
go

/*11.	Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch, 
thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:*/
create proc sp11 @ngaygd date, @thoigiangd time, @sotk varchar(15), 
@loaigd varchar(1), @sotien int, @trave nvarchar(100)
as
begin

--a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
if @ngaygd <> GETDATE() or @ngaygd is null 
						or DATEDIFF(MINUTE,@thoigiangd,GETDATE()) < 0 or @thoigiangd is null
begin
	set @trave = N'Ngày và thời gian giao dịch không hợp lệ'
	return 
end

--b. Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
declare @dem int
set @dem = (select count(Ac_no) from account where @sotk = Ac_no)
if @dem <= 0
	begin
		set @trave = N'Số tài khoản không tồn tại'
		return 
	end

--c. Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
if @loaigd <> 0 and @loaigd <> 1
	begin
		set @trave = N'Loại giao dịch không phù hợp'
		return
	end

--d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
if @sotien <= 0
	begin
		set @trave = N'Số tiền không hợp lệ'
		return
	end

--e. Tính mã giao dịch mới
declare @maMoi varchar(15), @maMax varchar(15), @len varchar(15)
set @maMax = (select MAX(t_id) from transactions)
set @maMoi = @maMax + 1
set @len = (select top 1 LEN(t_id) from transactions)
set @maMoi = REPLICATE ('0', @len - len(@maMoi)) + @maMoi

--f. Thêm mới bản ghi vào bảng TRANSACTIONS
insert into transactions (t_id, t_type, t_amount, t_date, t_time, ac_no)
values (@maMoi, @loaigd, @sotien, @ngaygd, @thoigiangd, @sotk)
if @@ROWCOUNT <= 0
	begin
		set @trave = N'Thêm mới bản ghi không thành công'
		return
	end

--g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch
if @loaigd = 1
	begin
		update account
		set ac_balance = ac_balance + @sotien
		where Ac_no = @sotk
	end
else 
	begin
		update account
		set ac_balance = ac_balance - @sotien
		where Ac_no = @sotk
	end
if @@ROWCOUNT <= 0
	begin 
		set @trave = N'Cập nhật không thành công'
	end
else
	begin
		set @trave = N'Cập nhật thành công'
	end
end

declare @trave nvarchar(100)
exec sp11 '2021-10-22', '07:31:00', '1000000141', '0', 3107000, @trave out
print @trave
go

/*12.	Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. 
Bao gồm những công việc sau:*/
create proc sp12 @makh varchar(15), @loaitk varchar(1), @sotien int, @trave nvarchar(100)
as
begin

--a. Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
declare @dem int
set @dem = (select count(Cust_id) from customer where @makh = Cust_id)
if @dem <= 0
	begin
		set @trave = N'Mã khách hàng không tồn tại'
		return
	end

--b. Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
if @loaitk <> 0 and @loaitk <> 1
	begin
		set @trave = N'Loại tài khoản không hợp lệ'
		return
	end

--c. Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
if @sotien is null
	begin
		set @sotien = 50000
	end
else if @sotien <= 0 
	begin
		set @trave = N'Số tiền không hợp lệ'
		return
	end

--d. Tính số tài khoản mới. Số tài khoản mới = MAX(các số tài khoản cũ) + 1
declare @idMoi varchar(15), @idMax varchar(15)
set @idMax = (select MAX(Ac_no) from account)
set @idMoi = @idMax + 1

--e. Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có
insert into account (Ac_no, ac_balance, ac_type, cust_id)
values (@idMoi, @sotien, @loaitk, @makh)
if @@ROWCOUNT > 0
	begin
		set @trave = N'Thêm mới thành công'
	end
else
	begin
		set @trave = N'Thêm mới thất bại'
	end
end

declare @trave nvarchar(100)
exec sp12 '000001', 2000000, 0, @trave out
print @trave














