--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã chi nhánh
create function f2 (@macn varchar(15))
returns table
as
	return select Cust_name, Cust_ad, Cust_phone 
	from customer join Branch on customer.Br_id = Branch.BR_id
	where @macn = customer.Cust_id

select * from dbo.f2('000002')

/* 13.	Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. 
Tồn tại trả về 1, không tồn tại trả về 0*/
create function f13 (@ten nvarchar(100), @sdt varchar(11))
returns int 
as
begin
	declare @trave int, @dem int
	select @dem = count(distinct(Cust_id)) from customer
	where @ten = Cust_name and @sdt = Cust_phone

	if @dem > 0
	begin 
		set @trave = 1
	end
	else
	begin
		set @trave = 0
	end
	return @trave
end

select dbo.f13(N'Hà Công Lực', '01638843209')

/*14. Tính mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: MAX(mã giao dịch đang có) + 1. 
Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
create function f14()
returns varchar(15)
as
begin
	declare @mamax varchar(15), @len varchar(15), @mamoi varchar(15)
	set @mamax = (select max(t_id) from transactions)
	set @mamoi = @mamax + 1
	set @len = (select top 1 len(t_id) from transactions)
	set @mamoi = REPLICATE('0', @len - len(@mamoi)) + @mamoi
	return @mamoi
end

select dbo. f14()

--15. Tính mã tài khoản mới. (định nghĩa tương tự như câu trên) 
create function f15()
returns varchar(15)
as
begin
	declare @mamax varchar(15), @len varchar(15), @mamoi varchar(15)
	set @mamax = (select max(Ac_no) from account)
	set @mamoi = @mamax + 1
	set @len = (select top 1 len(Ac_no) from account)
	set @mamoi = REPLICATE('0', @len - len(@mamoi)) + @mamoi
	return @mamoi
end

select dbo. f15()

-- 16. Trả về tên chi nhánh ngân hàng nếu biết mã của nó.
create function f16 (@maCN varchar(5))
returns nvarchar(100)
as
begin
	declare @ten nvarchar(100)
	select @ten = BR_name from Branch where @maCN = BR_id
	return @ten
end

select dbo. f16('VB002')

--17. Trả về tên của khách hàng nếu biết mã khách
create function f17 (@maKH varchar(6))
returns nvarchar(100)
as
begin
	declare @tenKH nvarchar(100)
	select @tenKH = Cust_name from customer where @maKH = Cust_id
	return @tenKH
end

select dbo. f17('000033')

--18. Trả về số tiền có trong tài khoản nếu biết mã tài khoản
create function f18 (@matk varchar(15))
returns money
as 
begin 
	declare @tien money
	select @tien = ac_balance from account
	where @matk = Ac_no
	return @tien
end

select dbo. f18(1000000001)

--19. Trả về số lượng khách hàng nếu biết mã chi nhánh
create function f19 (@macn varchar(15))
returns int
as
begin
	declare @sokh int
	select @sokh = count(Cust_id) from customer join Branch
	on customer.Br_id = Branch.BR_id
	where @macn = customer.Br_id
	return @sokh
end

select dbo.f19('VB001')

/*20. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. Giao dịch bất thường: 
giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am đến 3am */
create function f20 (@magd varchar(15))
returns nvarchar(50)
as
begin
	declare @loaigd int, @thoigian nvarchar(50), @trave nvarchar(50)
	select @loaigd = t_type, @thoigian = t_time
	from transactions
	where @magd = t_id

	if @loaigd = 1 and (@thoigian not between '07:30' and '11:30'
				   and @thoigian not between '13:30' and '16:00')
		set @trave = N'Giao dịch bất thường'
	else if @loaigd = 0 and @thoigian between '00:00' and '03:00'
		set @trave = N'Giao dịch bất thường'
	else
		set @trave = N'Giao dịch bình thường'
	return @trave
end

select dbo.f20(0000000204)

/*21. Sinh mã khách hàng tự động. 
Module này có chức năng tạo và trả về mã khách hàng mới bằng cách lấy MAX(mã khách hàng cũ) + 1 */
create function f21()
returns varchar(15)
as
begin
	declare @mamax varchar(15), @len varchar(15), @mamoi varchar(15)
	set @mamax = (select max(Cust_id) from customer)
	set @mamoi = @mamax + 1
	set @len = (select top 1 len(Cust_id) from customer)
	set @mamoi = REPLICATE('0', @len - len(@mamoi)) + @mamoi
	return @mamoi
end

select dbo.f21()

--22. Sinh mã chi nhánh tự động. Sơ đồ thuật toán của module 
create function f22 (@mavung varchar(15))
returns varchar(15)
as
begin
	declare @cNewID varchar(15)
	if exists (select * from Branch where left(BR_id, 2) = @mavung)
	begin
		declare @maxID varchar(10)
		select @maxID = max(RIGHT(br_id, 3)) + 1 
		from Branch where left(BR_id, 2) = @mavung
		set @cNewID = @mavung + REPLICATE('0', 3 - len(@maxID)) + @maxID
	end
	else
	begin
		set @cNewID = @mavung + '001'
	end
	return @cNewID
end

print dbo.f22('VB')
print dbo.f22('VT')
print dbo.f22('VN')



