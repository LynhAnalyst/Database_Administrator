/*1. Tạo thủ tục thực hiện xóa bản ghi trong bảng TRANSACTIONS với các công việc sau:
- Kiểm tra mã giao dịch đã tồn tại hay chưa. Nếu chưa tồn tại, kết thúc xử lý.
- Nếu loại giao dịch là gửi tiền. Thực hiện xóa bản ghi trong bản Transactions đồng thời cập nhật bảng account 
với sự thay đổi của cột ac_balance như sau: ac_balance = ac_balance – t_amount của giao tác vừa xóa
- Nếu là giao dịch rút tiền. Thực hiện xóa bản ghi trong bản transactions đồng thời cập nhật bản account 
với sự thay đổi của cột ac_balance như sau: ac_balance = ac_balance + t_amount của giao tác vừa xóa
Trong quá trình thực hiện, nếu bị lỗi ở 1 bước bất kì thì toán bộ dữ liệu quay trở lại trạng thái ban đầu.*/
create proc spDelTran @t_id varchar(10), @ret int out
as
begin
	declare @t_type int, @t_amount money, @ac_no varchar(10)
	if not exists (select * from transactions where t_id = @t_id)
	begin
		set @ret = 0
		return
	end
	select @t_type = t_type, @t_amount = t_amount, @ac_no = ac_no from transactions where t_id = @t_id
	if @t_type = 1
	begin
		delete transactions where t_id = @t_id
		if @@ROWCOUNT <= 0
		begin
			set @ret = 0
			return
		end
		update account 
		set ac_balance = ac_balance - @t_amount 
		where ac_no = @ac_no
		if @@ROWCOUNT <= 0 
		begin
			rollback transaction
			set @ret = 0
			return
		end
		else
		begin
			commit transaction
			set @ret = 1
			return
		end
	end
	if @t_type = 0
	begin
		delete transactions where @t_id = t_id
		if @@ROWCOUNT <= 0 
		begin
			set @ret = 0
			return
		end
		update account
		set ac_balance = ac_balance + @t_amount
		where @ac_no = ac_no
		if @@ROWCOUNT <= 0
		begin
			rollback transaction
			set @ret = 0
			return
		end
		else
		begin
			commit transaction
			set @ret = 1
			return
		end
	end
end
go

declare @ret int
exec spDelTran '0000000000', @ret out
print @ret
go

/*3. Thực hiện xóa khách hàng nếu biết mã khách hàng. Công việc cần làm gồm:
- Kiểm tra sự tồn tại của khách hàng dựa vào mã đã input. Nếu không tồn tại thì kết thúc
- Xóa tất cả những giao dịch của khách hàng này trong bảng transactions
- Xóa tất cả những tài khoản của khách hàng này trong bảng account
- Xóa dữ liệu của khách hàng với mã đã cho trong bảng customer
Hãy đảm bảo rằng dữ liệu chỉ được ghi nhận vào bảng nếu tất cả công việc nêu trên thực hiện thành công và 
không cho phép bất kỳ giao tác nào đọc dữ liệu đang chịu sự tác động của các thao tác đã nêu.*/
create proc spDelKH @maKH varchar(15), @kq int out
as
begin
	if not exists (select * from customer where Cust_id = @maKH)
	begin
		set @kq = 0
		return
	end

	begin transaction 
	delete from transactions 
	where t_id in (select t_id from transactions join account 
					on transactions.ac_no = account.Ac_no
					where cust_id = @maKH)
	if @@ROWCOUNT <= 0
	begin
		set @kq = 0
		return
	end

	delete from account where cust_id = @maKH
	if @@ROWCOUNT <= 0
	begin
		set @kq = 0
		rollback transaction
		return
	end

	delete from customer where Cust_id = @maKH
	if @@ROWCOUNT <= 0
	begin
		set @kq = 0
		rollback transaction
		return
	end
	else
	begin
		set @kq = 1
		commit transaction 
		return
	end
end

declare @kqua int
exec spDelKH '000001', @kqua out
print @kqua
select * from customer where Cust_id = '000002'

select * from customer
select * from account
select * from transactions



