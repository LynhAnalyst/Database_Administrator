/*1. Khi insert dữ liệu vào bảng transactions, hãy đảm bảo rằng ngày giao dịch không phải là ngày quá khứ */
-- loại trigger: after
-- sự kiện kích hoạt: insert
-- bảng: transactions
alter trigger t1
on transactions
after insert
as
begin
	-- muốn lấy data đang xử lý --> inserted
	declare @date date
	select @date = t_date from inserted
	if @date < cast(getdate() as date)
	begin 
		print 'Invalid data'
		rollback
	end
end

insert into transactions values ('999999', 0, 1000, '2023-03-28', '00:00:00', '1000000001')

select * from transactions

/*2. Sau khi xóa dữ liệu trong transactions hãy tính lại số dư trong bảng account:
a. Nếu là giao dịch rút: Số dư = Số dư cũ + t_amount
b. Nếu là giao dịch gửi: Số dư = Số dư cũ - t_amount */
create trigger t2
on transactions 
after delete
as
begin
	if (select t_type from transactions) = 1
		begin 
			update account
			set ac_balance = ac_balance - (select t_amount from deleted)
			where ac_no = (select ac_no from deleted)
		end 
	else
		begin 
			update account
			set ac_balance = ac_balance + (select t_amount from deleted)
			where ac_no = (select ac_no from deleted)
		end
	print N'Cập nhật thành công'
end

alter table transactions
disable trigger tType

delete from transactions where t_id = '999999'
select * from transactions

--3. Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự
create trigger t3
on customer
after update, insert
as
begin
	declare @ten nvarchar(100)
	select @ten = Cust_name from inserted
	if len(@ten) < 5
	begin
		print N'Tên khách hàng không nhở hơn 5 ký tự'
		rollback
	end
end

update customer
set Cust_name = N'Mai Huỳnh Phương Dung'
where Cust_id = '000001'

select * from customer

/*4. Khi xóa dữ liệu trong bảng transactions, hãy chuyển loại giao dịch thành 9
-- loại trigger: after
-- sự kiện kích hoạt: delete
-- bảng: transactions*/
create trigger t4
on transactions 
instead of delete
as
begin
	update transactions
	set t_type = 9
	where t_id = (select t_id from deleted)
	print N'Xóa thành công'
end

delete from transactions where t_id = '999999'
select * from transactions

/*5. Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
b.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
c.	Nếu là giao dịch rút: số dư = số dư – tiền rút. 
Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.*/
create trigger t5
on transactions
after insert
as
begin
	declare @loaitk int, @sodu money
	select @loaitk = t_type from inserted
	if @loaitk = 9
	begin 
		print N'Tài khoản đã bị xóa'
		rollback
	end
	else if @loaitk = 1
	begin
		update account
		set ac_balance = ac_balance + (select t_amount from inserted)
			where ac_no = (select ac_no from inserted)
	end
	else
	begin
		update account
		set ac_balance = ac_balance - (select t_amount from inserted)
			where ac_no = (select ac_no from inserted)
	end
	select @sodu = ac_balance from account
	if @sodu < 50000
	begin
		print N'Không đủ tiền'
		rollback
	end
end

/*6. Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư:
Số dư = số dư cũ + (số dữ mới – số dư cũ)*/
create trigger t6
on transactions
for update
as
begin
	declare @old_ac_balance money, @old_t_type int, @new_t_type int, @old_t_amount money, @new_t_amount money
	select @old_t_type = t_type, @old_t_amount = t_amount, @old_ac_balance = ac_balance from deleted join account on deleted.ac_no = account.Ac_no
	select @new_t_type = t_type, @new_t_amount = t_amount from inserted join account on inserted.ac_no = account.Ac_no
	if @old_t_type = 1
	begin
		set @old_ac_balance = @old_ac_balance - @old_t_amount
	end
	else if @old_t_type = 0
	begin
		set @old_ac_balance = @old_ac_balance + @old_t_amount
	end

	if @new_t_type = 1
	begin 
		update account
		set ac_balance = @old_ac_balance + @new_t_amount
		where Ac_no = (select ac_no from inserted)
	end
	else if @new_t_type = 0
	begin 
		update account
		set ac_balance = @old_ac_balance - @new_t_amount
		where Ac_no = (select ac_no from inserted)
	end
end

update transactions
--set t_type = 0
set t_amount = 1000
where t_id = '199999'

/*7. Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. 
Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện.*/
create trigger t7
on account
after insert, update, delete
begin
	declare @loaitk1 varchar(1), @loaitk2 varchar(1)
	select @loaitk1 = ac_type from inserted
	select @loaitk2 = ac_type from deleted
	if @loaitk1 = '9' and @loaitk2 is null --đây là trường hợp insert
		begin
			print N'Tài khoản đã bị xóa'
			rollback
		end
	else if @loaitk1 is null and @loaitk2 = '9' --đây là trường hợp delete
		begin
			print N'Tài khoản đã bị xóa'
			rollback
		end
	else if @loaitk1 is not null and @loaitk2 is not null --đây là trường hợp update (loaitk khác null)
		begin
			if @loaitk2 = '9'
			begin
				print N'Tài khoản đã bị xóa'
				rollback
			end
		end
end

delete from account where ac_type = '9'

insert into account (Ac_no, ac_balance, ac_type, cust_id)
values ('1000000056', 500000, '9', '000001')

select * from account where Ac_no = '1000000056'


/* 8. Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng
thì đưa ra thông báo "Đã tồn tại khách hàng" và hủy toàn bộ thao tác */
create trigger t8
on customer
instead of insert
as
begin
	declare @ten nvarchar(100), @sdt varchar(11)
	select @ten = Cust_name, @sdt = Cust_phone from customer
	where Cust_id = (select Cust_id from customer)
	rollback
	print N'Đã tồn tại khách hàng'
end

insert into customer (Cust_id, Cust_name, Cust_phone) 
values (000001, N'Hà Công Lực', 01283388103)

select * from customer

/*9. Khi thêm mới dữ liệu vào bảng account, hãy kiểm tra mã khách hàng. 
Nếu mã khách hàng chưa tồn tại trong bảng customer thì đưa ra thông báo 
‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác*/
create trigger t9
on account
after insert
as
begin
	declare @makh varchar(15), @dem int
	select @makh = cust_id from inserted
	set @dem = (select count(@makh) from inserted)
	if @dem = 0
	begin
		print N'Khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
		rollback
	end
end

insert into account (Ac_no, ac_balance, ac_type, cust_id)
values ('1000000059', 5000, '1', '000002')

select * from account

 