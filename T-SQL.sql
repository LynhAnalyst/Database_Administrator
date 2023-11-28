/*1. Viết đoạn code thực hiện việc chuyển đổi đầu số điện thoại di động theo quy định của bộ 
Thông tin và truyền thông cho một khách hàng bất kì, ví dụ với: Dương Ngọc Long */
declare @soDT varchar(15), @lenSDT varchar(2)

select @soDT = Cust_phone
from customer
where Cust_name = N'Dương Ngọc Long'
print N'Số điện thoại hiện tại của Dương Ngọc Long:' + @soDT

select @lenSDT = len (Cust_phone)
from customer
where Cust_name = N'Dương Ngọc Long'
print N'Độ dài số điện thoại là: ' + @lenSDT

if @lenSDT > 10
begin
	update customer
	set @soDT = case when @soDT like '016%'		then '03' + RIGHT (Cust_phone,8)
					 when @soDT like '01[8,9]%' then '05' + RIGHT (Cust_phone,8)
					 when @soDT like '0120%'	then '070' + RIGHT (Cust_phone,7)
					 when @soDT like '0121%'	then '079' + RIGHT (Cust_phone,7)
					 when @soDT like '0122%'	then '077' + RIGHT (Cust_phone,7)
					 when @soDT like '0126%'	then '076' + RIGHT (Cust_phone,7)
					 when @soDT like '0128%'	then '078' + RIGHT (Cust_phone,7)
					 when @soDT like '0123%'	then '083' + RIGHT (Cust_phone,7)
			 		 when @soDT like '0124%'	then '084' + RIGHT (Cust_phone,7)
					 when @soDT like '0125%'	then '085' + RIGHT (Cust_phone,7)
					 when @soDT like '0127%'	then '081' + RIGHT (Cust_phone,7)
					 when @soDT like '0129%'	then '082' + RIGHT (Cust_phone,7) 
					 else Cust_phone
				end
	where Cust_name = N'Dương Ngọc Long'
	print N'Số điện thoại sau khi được cập nhật của Dương Ngọc Long:' + @soDT
end
else
begin
	print N'Số điện thoại hiện tại của Dương Ngọc Long: ' + @soDT
end

/*2. Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân 
có thực hiện giao dịch nào không? Nếu có, hãy trừ 50.000 phí duy trì tài khoản. */
declare @soGD int, @sotien int
select @soGD = (select count(t_id)
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Nguyễn Lê Minh Quân' and DATEDIFF(year,t_date,GETDATE()) <= 10)
if @soGD > 0
begin
	update account 
	set @sotien = (select ac_balance - 50000 
	from customer join account on customer.Cust_id = account.cust_id
	where Cust_name = N'Nguyễn Lê Minh Quân')
	print N'Số giao dịch: ' + cast(@soGD as varchar(11))
	print N'Số tiền: ' + cast(@sotien as varchar(11)) 
end

/*3. Trần Quang Khải thực hiện giao dịch gần đây nhất vào thứ mấy? 
(thứ hai, thứ ba, thứ tư,…, chủ nhật) và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)? */
declare @ngayGD date, @thu nvarchar(20), @mua nvarchar(20)

set @ngayGD = (select top 1 t_date
				 from transactions join account on transactions.ac_no = account.Ac_no
								   join customer on account.cust_id = customer.Cust_id
				 where Cust_name = N'Trần Quang Khải' 
				 order by t_date DESC, t_time DESC)
print @ngayGD

set @thu = case DATEPART(DW,@ngayGD) when 2 then N'Thứ hai'
									   when 3 then N'Thứ ba'
									   when 4 then N'Thứ tư'
									   when 5 then N'Thứ năm'
									   when 6 then N'Thứ sáu'
									   when 7 then N'Thứ bảy'
									   else N'Chủ nhật'
			end
print @thu

set @mua = case DATEPART(QQ,@ngayGD) when 1 then N'Mùa xuân'
									   when 2 then N'Mùa hạ'
									   when 3 then N'Mùa thu'
									   else N'Mùa đông'
		   end 
print @mua

/*4. Đưa ra nhận xét về nhà mạng mà Lê Anh Huy đang sử dụng? (Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)*/
declare @sdt varchar(11), @nx varchar(12)
select @sdt = (select Cust_phone from customer where Cust_name = N'Lê Anh Huy')
set @nx = case
when @sdt like '086%' or @sdt like '09[6,7,8]%' or @sdt like '016[2-9]%' or @sdt like '03[2-9]%' then 'Viettel'
when @sdt like '089%' or @sdt like '09[0,3]%' or @sdt like '012[0,1,2,6,8]%' or @sdt like '07%' then 'Mobiphone'
when @sdt like '088%' or @sdt like '09[1,4]%' or @sdt like '012[3,4,5,7,9]%' or @sdt like '08%' then 'Vinaphone'
when @sdt like '092%' or @sdt like '018[2,6,8]%' or @sdt like '05[2,6,8]%' then 'Vietnamobile'
else N'Khác'
end
print @nx

/*5. Số điện thoại của Trần Quang Khải là số tiến, số lùi hay số lộn xộn. 
Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến, ví dụ: 098356789 là số tiến */
declare @sdt varchar(8), @kt varchar(10) = ''
select @sdt = (select SUBSTRING(Cust_phone, 4, len(Cust_phone) - 3)
from customer where Cust_name = N'Trần Quang Khải')

while len(@sdt) > 1
begin
	if SUBSTRING(@sdt,1,1) > SUBSTRING(@sdt,2,1)
		set @kt = @kt + '>'
	else if SUBSTRING(@sdt,1,1) < SUBSTRING(@sdt,2,1)
		set @kt = @kt + '<'
	else 
	    set @kt = @kt + '='
	set @sdt = SUBSTRING(@sdt,2,LEN(@sdt)-1)
end 

if @kt not like ('%>%')
	print N'Số Tiến'
else if @kt not like ('%<%')
	print N'Số Lùi'
else 
	print N'Số Lộn Xộn'

/*6. Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi nào(sáng, trưa, chiều, tối, đêm)? */
declare @gd time, @nx nvarchar(5)
select @gd = (select top 1 t_time
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Hà Công Lực' 
order by t_date DESC, t_time DESC)

set @nx = case
when @gd between '01:00' and '10:00' then N'Sáng'
when @gd between '11:00' and '12:00' then N'Trưa'
when @gd between '13:00'  and '18:00' then N'Chiều'
when @gd between '19:00' and '21:00' then N'Tối'
when @gd between '22:00' and '24:00' then N'Đêm'
end
print @nx

/*7. Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền nào? 
Gợi ý: nếu mã chi nhánh là VN là miền nam, VT là miền trung, VB là miền bắc, còn lại: bị sai mã. */
declare @chinhanh varchar(5), @mien nvarchar(10)
select @chinhanh = (select Branch.Br_id
from Branch join customer on Branch.BR_id = customer.Br_id
where Cust_name = N'Trương Duy Tường')
set @mien = case
when @chinhanh like 'VN%' then N'miền nam'
when @chinhanh like 'VT%' then N'miền trung'
when @chinhanh like 'VB%' then N'miền bắc'
else N'bị sai mã'
end
print @mien

/*8. Căn cứ vào số điện thoại của Trần Phước Đạt, 
hãy nhận định anh này dùng dịch vụ di động của hãng nào: Viettel, Mobi phone, Vina phone, hãng khác. */
declare @sodt varchar(11), @hang varchar(10)
select @sodt = (select Cust_phone from customer where Cust_name = N'Trần Phước Đạt')
set @hang = case
when @sodt like '086%' or @sodt like '09[6,7,8]%' or @sodt like '016[2-9]%' or @sodt like '03[2-9]%' then 'Viettel'
when @sodt like '089%' or @sodt like '09[0,3]%' or @sodt like '012[0,1,2,6,8]%' or @sodt like '07%' then 'Mobiphone'
when @sodt like '088%' or @sodt like '09[1,4]%' or @sodt like '012[3,4,5,7,9]%' or @sodt like '08%' then 'Vinaphone'
when @sodt like '092%' or @sodt like '018[2,6,8]%' or @sodt like '05[2,6,8]%' then 'Vietnamobile'
else N'Khác' 
end 
print @hang

/*9. Hãy nhận định Lê Anh Huy ở vùng nông thôn hay thành thị. 
Gợi ý: nông thôn thì địa chỉ thường có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện” */
declare @vung nvarchar(100), @kq nvarchar(10)
select @vung = (select Cust_ad from customer where Cust_name = N'Lê Anh Huy')
set @kq = case 
when (@vung like N'%thôn' or @vung like N'%xóm' or @vung like N'%đội'or @vung like N'%huyện') 
and @vung not like N'%thị xã' then N'Nông thôn'
else N'Thị xã'
end
print @kq

/*10. Hãy kiểm tra tài khoản của Trần Văn Thiện Thanh, nếu tiền trong tài khoản của anh ta nhỏ hơn không hoặc 
bằng không nhưng 6 tháng gần đây không có giao dịch thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’ */
declare @tien varchar(11), @gd varchar(10)
select @tien = (select sum(ac_balance)
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Trần Văn Thiện Thanh')
print @tien

select @gd = (select count(t_id) 
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where datediff(m,t_date,getdate()) <= 6 and Cust_name = N'Trần Văn Thiện Thanh')
print @gd

if @tien <= 0 and @gd = 0 
begin 
	update account
	set ac_type = 'K' 
	from account join customer on account.cust_id = customer.Cust_id
	where Cust_name = N'Trần Văn Thiện Thanh'

	if @@ROWCOUNT > 0
	begin
		print N'Cập nhật thành công'
	end
	else 
	begin
		print N'Cập nhật không thành công'
	end
end
else
begin 
	print N'Không thể cập nhật'
end

--11. Mã số giao dịch gần đây nhất của Huỳnh Tấn Dũng là số chẵn hay số lẻ? 
declare @maGD varchar(15)
select @maGD = (select top 1 t_id 
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Huỳnh Tấn Dũng'
order by t_date DESC, t_time DESC)
if @maGD %2 = 0
begin 
	print N'Số chẵn'
end
else
begin
	print N'Số lẻ'
end

/*12. Có bao nhiêu giao dịch diễn ra trong tháng 9/2016 với tổng tiền mỗi loại là bao nhiêu
(bao nhiêu tiền rút, bao nhiêu tiền gửi)*/
declare @solanGD varchar(5), @tiengui varchar(10), @tienrut varchar(15)
select @solanGD = (select count(t_id) from transactions 
where DATEPART(MONTH,t_date) = 9 and DATEPART(year,t_date) = 2016)
print N'Có ' + @solanGD + N' giao dịch trong tháng 9/2016'

select @tiengui = (select sum(t_amount) from transactions
where DATEPART(MONTH,t_date) = 9 and DATEPART(year,t_date) = 2016 and t_type = 1)
if @tiengui > 0
begin
	print N'Tổng tiền gửi là: ' + @tiengui
end 
else
begin
	print N'Không có giao dịch gửi tiền '
end

select @tienrut = (select sum(t_amount) from transactions
where DATEPART(MONTH,t_date) = 9 and DATEPART(year,t_date) = 2016 and t_type = 0)
if @tienrut > 0
begin
	print N'Tổng tiền rút là: ' + @tienrut
end
else
begin
	print N'Không có giao dịch rút tiền'
end

/*13. Ở Hà Nội ngân hàng Vietcombank có bao nhiêu chi nhánh và có bao nhiêu khách hàng? 
Trả lời theo mẫu: “Ở Hà Nội, Vietcombank có … chi nhánh và có …khách hàng” */
declare @cn varchar(10), @kh varchar(10)
select @cn = (select count(BR_id) from Branch join Bank
on Branch.B_id = Branch.B_id
where b_name = N'Ngân hàng Công thương Việt Nam' and BR_name like N'%Hà Nội%')

select @kh = (select count(customer.Cust_id) from Bank join Branch on Bank.b_id = Branch.B_id
join customer on Branch.BR_id = customer.Br_id
where b_name = N'Ngân hàng Công thương Việt Nam' and BR_name like N'%Hà Nội%')

print N'Ở Hà Nội, Vietcombank có ' + @cn + N' chi nhánh và có ' + @kh + N' khách hàng'

/*14. Tài khoản có nhiều tiền nhất là của ai, số tiền hiện có trong tài khoản đó là bao nhiêu? 
Tài khoản này thuộc chi nhánh nào?*/
declare @tien varchar(10), @tk nvarchar(100), @cn nvarchar(100)
select @tien = ac_balance, @tk = Cust_name, @cn = BR_name
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
where ac_balance = (select max(ac_balance) from account)
print @tien
print @tk
print @cn

--15. Có bao nhiêu khách hàng ở Đà Nẵng?
declare @tk varchar(10)
select @tk = (select count(Cust_id) from customer where Cust_ad like N'%Đà Nẵng%')
print @tk

--16. Có bao nhiêu khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn
declare @sotk varchar(10)
select @sotk =
(select count(Cust_id) from customer join Branch
on customer.Br_id = Branch.BR_id
where Cust_ad like N'%Quảng Nam%' and BR_name like N'%Sài Gòn%')
print @sotk

-- 17. Ai là người thực hiện giao dịch có mã số 0000000387, thuộc chi nhánh nào? Giao dịch này thuộc loại nào?
declare @ten nvarchar(100), @cn nvarchar(100), @gd char(1)
select @ten = Cust_name, @cn = BR_name, @gd = t_type
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id 
join transactions on account.Ac_no = transactions.ac_no
where t_id = 0000000387 
print @ten
print @cn
print @gd

/*18. Hiển thị danh sách khách hàng gồm: họ và tên, số điện thoại, số lượng tài khoản đang có và nhận xét. 
Nếu < 1 tài khoản là “Bất thường”, còn lại “Bình thường”*/
declare @ds table (HoTen nvarchar(50),
						 SoDT varchar(15),
						 SLTK int,
						 NhanXet nvarchar(15)
						 )
insert into @ds select Cust_name, Cust_phone, SLTK = COUNT(Ac_no), NhanXet = case when COUNT(Ac_no) < 1 then N'Bất thường'
																						else N'Bình thường'
																				   end
					  from customer join account on customer.Cust_id = account.cust_id
					  group by Cust_name,Cust_phone
select * from @ds

/*19. Viết đoạn code nhận xét tiền trong tài khoản của ông Hà Công Lực. 
<100.000: ít, < 5.000.000: trung bình, còn lại: nhiều*/
declare @t varchar(15)
select @t = (select sum(ac_balance)
from customer join account on customer.Cust_id = account.cust_id
where Cust_name = N'Hà Công Lực')
print @t

if @t < 100000
begin
	print N'Ít'
end
else if @t between 100000 and 5000000
begin 
	print N'Trung bình'
end 
else
begin
	print N'Nhiều'
end

--20.
declare @ds table 
(
	maGD varchar(10),
	tgGD varchar(16),
	tien int,
	loaiGD nvarchar(3),
	stk varchar(11)
)
insert into @ds select t_id,
concat_ws(' ',t_date, left(t_time,5)), 
t_amount, 
t_type = case
when t_type = 1 then N'Gửi'
else 'Rút'
end, 
account.ac_no
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where BR_name like N'%Huế'

select * from @ds

--21. Kiểm tra xem khách hàng Nguyễn Đức Duy có ở Quang Nam hay không?
declare @dc nvarchar(150)
select @dc = (select Cust_ad from customer where Cust_name = N'Nguyễn Đức Duy')
if @dc like N'%Quảng Nam%'
begin
	print N'Ở Quảng Nam'
end
else
begin
	print N'Không ở Quảng Nam'
end

/*22. Điều tra số tiền trong tài khoản ông Lê Quang Phong có hợp lệ hay không? 
(Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). 
Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, ngược lại hãy cập nhật lại tài khoản sao cho số tiền 
trong tài khoản khớp với tổng số tiền đã giao dịch (ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút) */
declare @tien int, @tiengui int, @tienrut int

select @tien = (select account.ac_balance
from customer join account on customer.Cust_id = account.cust_id
where Cust_name = N'Lê Quang Phong') 

select @tiengui = (select sum(t_amount)
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Lê Quang Phong' and t_type = 1) 

select @tienrut = (select sum(t_amount)
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Lê Quang Phong' and t_type = 0) 

print N'Tổng tiền gửi là: ' + @tiengui
print N'Tổng tiền gửi là: ' + @tienrut

if @tiengui - @tienrut = @tien
begin
	print N'Hợp Lệ'
end

else 
begin
	update account
	set @tien = @tiengui - @tienrut
	from account join customer on account.cust_id=customer.Cust_id
	where customer.Cust_name = N'Lê Quang Phong'

	if @@ROWCOUNT > 0
		print N'Thành Công'
	else
		print N'Không Thành Công'
end

/*23. Chi nhánh Đà Nẵng có giao dịch gửi tiền nào diễn ra vào ngày chủ nhật hay không? 
Nếu có, hãy hiển thị số lần giao dịch, nếu không, hãy đưa ra thông báo “không có” */
declare @gd varchar(10)
select @gd = (select count(t_id)
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where t_type = 1 and datepart(dw,t_date) not in (2,3,4,5,6,7) and BR_name like N'%Đà Nẵng')
if @gd > 0 
begin
	print N'Số giao dịch là: ' + @gd
end
else
begin
	print N'Không có'
end

/*24. Kiểm tra xem khu vực miền bắc có nhiều phòng giao dịch hơn khu vực miền trung ko? 
Miền bắc có mã bắt đầu bằng VB, miền trung có mã bắt đầu bằng VT */
declare @gdB varchar(10), @gdT varchar(10)
select @gdB = (select count(Branch.Br_id)
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Branch.Br_id like 'VB%')

select @gdT = (select count(Branch.Br_id)
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Branch.Br_id like 'VT%')

if @gdB > @gdT
begin
	print N'Khu vực miền Bắc có nhiều phòng giao dịch hơn khu vực miền Trung'
end

--VÒNG LẶP
--1. In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn
declare @i int = 1, @n int = 10
while (@i < @n)
begin
	if(@i%2 = 0)
	begin
		set @i = @i +1
		continue
	end
	else
		print @i
		set @i = @i + 1
end

--2. In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn
declare @i int = 0, @n int = 10
while @i < (@n + 1)
begin 
	if (@i % 2 != 0)
	begin
		set @i = @i + 1
		continue
	end 
	else
	begin 
		print @i
		set @i = @i + 1
	end
end

/*3. In ra 100 số đầu tiền trong dãy số Fibonaci*/
declare @f numeric(30,0), @f1 numeric(30,0), @f2 numeric(30,0), @i3 int
set @f1=1
set @f2=1
set @i3=1
while @i3 <= 100
	begin
		if (@i3=1) or (@i3=2)
		begin 
			set @f=1
		end
		else
		begin
			set @f = @f1 + @f2
			set @f1 = @f2
			set @f2 = @f
		end
		print @f
		set @i3 = @i3 + 1
	end

/*4. In ra tam giác sao: 1 tam giác vuông, 1 tam tam giác cân như ví dụ dưới đây:*/
declare @star varchar(15)
set @star = '*'
while len(@star) <= 5
	begin
		print @star
		set @star = @star + '*'
	end

declare @n int
set @n = 1
while (@n<=4)
begin
  print replicate (' ',9 - 2*@n-1) + replicate('* ',2*@n-1)
  set @n=@n+1
end

/*5. In bảng cửu chương*/
declare @i int, @j int
set @i = 1
while @i <= 9
	begin
		print N'Bảng cửu chương ' + cast(@i as varchar(5))
		set @j = 1
		while @j <= 10
		begin
			print cast(@i as varchar(5)) + ' x '+ cast(@j as varchar(5)) + ' = ' + cast(@j * @i as varchar(5))
		set @j = @j + 1
		end
		set @i = @i + 1
	end

/*6. Viết đoạn code đọc số. Ví dụ: 1.234.567 
Một triệu hai trăm ba mươi tư ngàn năm trăm sáu mươi bảy đồng. (Giả sử số lớn nhất là hàng trăm tỉ)*/
declare @i int, @j int, @x int,@y int = 1, @doc nvarchar(100) = N' đồng.', @a varchar(15) ='4581365476'
set @j=len(@a)%3
set @i = case when @j=0 then len(@a)/3
			else len(@a)/3+1
		end 
while @y<@i
	begin
	set @x=1
	while @x<=3
		begin
		if substring(@a,len(@a),1)=0 set @doc=N' không'+@doc
		else if substring(@a,len(@a),1)=1 set @doc=N' một'+@doc
		else if substring(@a,len(@a),1)=2 set @doc=N' hai'+@doc
		else if substring(@a,len(@a),1)=3 set @doc=N' ba'+@doc
		else if substring(@a,len(@a),1)=4 set @doc=N' bốn'+@doc
		else if substring(@a,len(@a),1)=5 set @doc=N' năm'+@doc
		else if substring(@a,len(@a),1)=6 set @doc=N' sáu'+@doc
		else if substring(@a,len(@a),1)=7 set @doc=N' bảy'+@doc
		else if substring(@a,len(@a),1)=8 set @doc=N' tám'+@doc
		else set @doc=N' chín'+@doc
		set @x=@x+1
		if @x=2 set @doc=N' mươi'+@doc
		else if @x=3 set @doc=N' trăm'+@doc
		set @a=left(@a,len(@a)-1)
		end
	set @y=@y+1
	if @y=2 set @doc=N' ngàn'+@doc
	else if @y=3 set @doc=N' triệu'+@doc
	else if @y=4 set @doc=N' tỷ'+@doc
	end
set @x=1
while @x<=@j
	begin
	if substring(@a,len(@a),1)=0 set @doc=N' không'+@doc
	else if substring(@a,len(@a),1)=1 set @doc=N' một'+@doc
	else if substring(@a,len(@a),1)=2 set @doc=N' hai'+@doc
	else if substring(@a,len(@a),1)=3 set @doc=N' ba'+@doc
	else if substring(@a,len(@a),1)=4 set @doc=N' tư'+@doc
	else if substring(@a,len(@a),1)=5 set @doc=N' năm'+@doc
	else if substring(@a,len(@a),1)=6 set @doc=N' sáu'+@doc
	else if substring(@a,len(@a),1)=7 set @doc=N' bảy'+@doc
	else if substring(@a,len(@a),1)=8 set @doc=N' tám'+@doc
	else set @doc=N' chín'+@doc
	set @x=@x+1
	if (@x=2) and (@x<>@j+1) set @doc=N' mươi'+@doc
	else if (@x=3) and (@x<>@j+1)set @doc=N' trăm'+@doc
	set @a=left(@a,len(@a)-1)
	end
set @doc=Right(@doc,len(@doc)-1)
print @doc

/*7. Kiểm tra số điện thoại của Lê Quang Phong là số tiến hay số lùi. 
Gợi ý:
	Với những số điện thoại có 10 số, thì trừ 3 số đầu tiên, 
	nếu số sau lớn hơn hoặc bằng số trước thì là số tiến, ngược lại là số lùi. 
	Ví dụ: 0981.244.789 (tiến), 0912.776.541 (lùi), 0912.563.897 (lộn xộn)
	Với những số điện thoại có 11 số thì trừ 4 số đầu tiên. */
declare @sdt7 varchar(15), @kt7 varchar(10) = ''
select @sdt7 = RIGHT(Cust_phone,7)
from customer where Cust_name = N'Lê Quang Phong'
print @sdt7
while LEN(@sdt7) > 1
begin
	if SUBSTRING(@sdt7,1,1) > SUBSTRING(@sdt7,2,1)
		set @kt7 = @kt7 + '>'
	else if SUBSTRING(@sdt7,1,1) < SUBSTRING(@sdt7,2,1)
		set @kt7 = @kt7 + '<'
	else 
	    set @kt7 = @kt7 + ''
	set @sdt7 = RIGHT(@sdt7,len(@sdt7)-1)
end 
if @kt7 not like ('%>%')
	print N'Số Tiến'
else if @kt7 not like ('%<%')
	print N'Số Lùi'
else 
	print N'Số Lộn Xộn'
