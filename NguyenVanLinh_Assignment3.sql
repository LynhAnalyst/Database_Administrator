-- Nguyễn Văn Linh

-- Câu 1. Viết module trả về mã hàng mới, biết rằng: mã hàng = MAX(mã hàng) + 1
create proc spMaHangMoi @mamoi int out
as
begin 
	declare @mamax int
	set @mamax = (select max(MaHang) from Hang)
	set @mamoi = @mamax + 1
end
go

declare @mamoi int 
exec spMaHangMoi @mamoi out
print @mamoi
go

/*Câu 2. Viết module thực hiện việc thêm dữ liệu cho bảng DonBanChiTiet với tham số đầu vào là: 
mã đơn bán, mã hàng, số lượng. Công việc gồm:
--Kiểm tra sự tồn tại của mã đơn bán. Nếu mã đơn bán không tồn tại trong bảng DonBan thì thông báo lỗi và kết thúc
--Kiểm tra sự tồn tại của mã hàng. Nếu mã hàng không tồn tại trong bảng Hang thì thông báo lỗi và kết thúc
--Kiểm tra số lượng hàng. Nếu nhỏ hơn hoặc bằng 0 thì thông báo lỗi và kết thúc
--Tính ThanhTien = số lượng * giá bán của trong bảng HANG của mã hàng tương ứng
--Thêm mới bản ghi vào bảng DonBanChiTiet với các giá trị đã có và đưa ra thông báo kết quả của việc thêm mới.*/
create proc spmodule @madonban int, @mahang int, @soluong int, @trave nvarchar(100) out
as
begin
	--Kiểm tra sự tồn tại của mã đơn bán. Nếu mã đơn bán không tồn tại trong bảng DonBan thì thông báo lỗi và kết thúc
	declare @dem1 int 
	set @dem1 = (select count(MaDonBan) from DonBan where @madonban = MaDonBan)

	if @dem1 <= 0
		begin
			set @trave = N'Mã đơn bán không tồn tại'
			return
		end
	
	--Kiểm tra sự tồn tại của mã hàng. Nếu mã hàng không tồn tại trong bảng Hang thì thông báo lỗi và kết thúc
	declare @dem2 int 
	set @dem2 = (select count(MaHang) from Hang where @mahang = MaHang)

	if @dem2 <= 0
		begin
			set @trave = N'Mã hàng không tồn tại'
			return
		end

	--Kiểm tra số lượng hàng. Nếu nhỏ hơn hoặc bằng 0 thì thông báo lỗi và kết thúc
	set @soluong = (select sum(SoLuong) from DonBanChiTiet)
	if @soluong <= 0
		begin
			set @trave = N'Số lượng hàng không hợp lệ'
			return
		end

	--Tính ThanhTien = số lượng * giá bán của trong bảng HANG của mã hàng tương ứng
	update DonBanChiTiet
	set ThanhTien = SoLuong * GiaBan
	from Hang inner join DonBanChiTiet
	on Hang.MaHang = DonBanChiTiet.MaHang

	--Thêm mới bản ghi vào bảng DonBanChiTiet với các giá trị đã có và đưa ra thông báo kết quả của việc thêm mới
	insert into DonBanChiTiet(MaDonBan, MaHang, SoLuong)
	values (@madonban, @mahang, @soluong)

	if @@ROWCOUNT > 0
		begin
			set @trave = N'Thêm mới thành công'
		end
	else
		begin
			set @trave = N'Thêm mới thất bại'
		end
end
go

declare @trave nvarchar(100)
exec spmodule 2, 1, 12, @trave out
print @trave
go

-- Câu 3. Khi người dùng xóa dữ liệu ở bảng CongNo, hãy thực hiện cập nhật dữ liệu đó với TrangThai = 5.
create trigger tXoaDuLieu
on CongNo
instead of delete
as
begin
	update CongNo
	set TrangThai = 5
	where MaCN = (select MaCN from deleted)
	print N'Xóa thành công'
end

delete from CongNo where MaCN = 1
select * from CongNo

