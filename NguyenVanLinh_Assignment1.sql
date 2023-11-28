--1.	Tìm những khách hàng có địa chỉ ở Ngũ Hành Sơn – Đà nẵng
select Cust_id, Cust_name,Cust_phone,Cust_ad from customer
where Cust_ad like N'%Đà Nẵng' and Cust_ad like N'%Ngũ Hành Sơn%'

--2.	Liệt kê những chi nhánh chưa có địa chỉ
select BR_id, BR_name,BR_ad from Branch
where BR_ad = ''

--3.	Liệt kê những giao dịch rút tiền bất thường (nhỏ hơn 50.000)
select t_id, t_type, t_amount, t_date from transactions
where t_type = 0 and  t_amount < 50000

--4.	Hiển thị danh sách khách hàng có kí tự thứ 3 từ cuối lên là chữ a, u, i
select Cust_id, Cust_name,Cust_phone,Cust_ad from customer
where Cust_name like N'%[a,u,i]__'

/*5.	Hiển thị khách hàng có địa chỉ sống ở vùng nông thôn. 
Với quy ước: nông thôn là vùng mà địa chỉ chứa: thôn, xã, xóm*/
select Cust_id, Cust_name,Cust_phone,Cust_ad from customer
where Cust_ad like N'%thôn%' or Cust_ad like N'%xóm%' 
or (Cust_ad like N'%xã%' and Cust_ad not like N'%thị xã%')

/*6.	Trong quý 1 năm 2012, hiển thị danh sách khách hàng 
thực hiện giao dịch rút tiền tại Ngân hàng Vietcombank?*/
select Cust_name,Cust_phone,Cust_ad 
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id=account.cust_id
inner join transactions on account.Ac_no=transactions.ac_no
where datepart(quarter,t_date) = 1 and datepart(year,t_date) = 2012 and BR_name like N'Vietcombank%' and t_type = 0

--7.	Liệt kê những giao dịch thực hiện cùng giờ với giao dịch Lê Nguyễn Hoàng Văn trong năm 2016
select t_id, t_type, t_amount, t_date
from transactions
where t_time = (select t_time
				from transactions join account on transactions.ac_no = account.Ac_no
								  join customer on account.cust_id = customer.Cust_id
				where datepart(year,t_date) = 2016 and Cust_name = N'Lê Nguyễn Hoàng Văn')

--8.	Liệt kê các giao dịch của chi nhánh Huế năm 2016
select t_id, t_type, t_amount, t_date
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id=account.cust_id
inner join transactions on account.Ac_no=transactions.ac_no
where datepart(year,t_date) = 2016 and BR_name like N'%Huế'

--9.	Hiển thị tên, họ và tên đệm của các khách hàng (2 cột khác nhau)
select Cust_id, Cust_name as N'Họ và tên đệm',
		SUBSTRING(Cust_name, 1, LEN(Cust_name) - CHARINDEX(' ', REVERSE(Cust_name))) as N'Tên đệm', 
		LTRIM(RIGHT (Cust_name, CHARINDEX(' ', REVERSE(Cust_name)))) as N'Tên'
from customer

--10.	Hiển thị tên thành phố/tỉnh của khách hàng
select cust_ad, 
		ltrim(rtrim(iif(CHARINDEX(',', REVERSE(Cust_ad)) > 0,
		iif(len(RIGHT(Cust_ad,CHARINDEX(',', REVERSE(cust_ad))-1)) < 20,
		right(Cust_ad,CHARINDEX(',', REVERSE(cust_ad))-1),RIGHT(Cust_ad, CHARINDEX(' ',REVERSE(cust_ad),7)-1)),
		right(Cust_ad,CHARINDEX('-', REVERSE(cust_ad))-1)))) as N'Tỉnh/TP' from customer

/*11.	Ai là người thực hiện giao dịch gửi tiền vào ngày 27/09/2013, 
họ thực hiện giao dịch đó ở chi nhánh nào, với lượng tiền bằng bao nhiêu*/
select Cust_name, Cust_phone, BR_name, t_amount
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id = account.cust_id
inner join transactions on account.Ac_no = transactions.ac_no
where t_date = '2013/09/27' and t_type = 1

/*12.	Ông Nguyễn Lê Minh Quân đã thực hiện những giao dịch nào? 
Hãy đưa ra tên chi nhánh, thời gian, loại giao dịch và số tiền mỗi lần giao dịch*/
select BR_name, t_date, t_time, t_type, t_amount
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id = account.cust_id
inner join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Nguyễn Lê Minh Quân' 

/*13.	Từ tháng 5 đến tháng 12  năm 2014, 
chi nhánh Huế có những khách hàng nào tới thực hiện giao dịch, loại giao dịch là gì, số tiền là bao nhiêu?*/
select Cust_name, t_type, t_amount, t_date
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id = account.cust_id
inner join transactions on account.Ac_no = transactions.ac_no
where (DATEPART(MONTH,t_date) between 5 and 12) and DATEPART(year,t_date) = 2014 and BR_name = N'%Huế'

--14.	Liệt kê những khách hàng sử dụng số điện thoại của Viettel và chưa thực hiện giao dịch nào
select Cust_name, Cust_phone
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id = account.cust_id
inner join transactions on account.Ac_no = transactions.ac_no
where Cust_phone like '016[7,8,9]%' and t_type = ''

/*15.	Hiển thị danh sách khách hàng đăng kí sử dụng 
dịch vụ của ngân hàng ở chi nhánh khác nơi ở của họ (chỉ tính khác ở mức thành phố)*/
select Cust_name, Cust_ad, BR_name
from customer inner join Branch on Branch.BR_id = customer.Br_id
			  inner join account on customer.Cust_id = account.cust_id
where customer.Cust_ad <> Branch.BR_ad

/*16.	Hiển thị danh sách khách hàng chưa cập nhật số điện thoại 
theo quy định mới của chính phủ (những số điện thoại có 11 số)*/
select Cust_name, Cust_phone, Cust_ad from customer
where len(Cust_phone) = 11 

/*17.	Mùa xuân năm 2013, có những khách hàng nào thực hiện giao dịch, 
hiển thị loại giao dịch, lượng tiền giao dịch và chi nhánh giao dịch của họ*/
select Cust_name, t_type, t_amount, BR_name
from (Branch inner join customer on Branch.BR_id=customer.Br_id)
inner join account on customer.Cust_id = account.cust_id
inner join transactions on account.Ac_no = transactions.ac_no
where DATEPART(YEAR,t_date) = 2013 and DATEPART(QUARTER,t_date) between 1 and 3 

--18.	Hiển thị những giao dịch gửi tiền thực hiện vào ngày thứ 7 hoặc chủ nhật (giao dịch bất thường)
select t_id, t_type, t_amount, t_date from transactions
where DATENAME(WEEKDAY, t_date) <> 'Saturday' and DATENAME(WEEKDAY, t_date) <> 'Sunday' and t_type = 1

--19.	Chi nhánh nào không có khách hàng?
select BR_name, BR_ad
from Branch left join customer on Branch.BR_id = customer.Br_id
where Cust_id is null

--20.	Tài khoản nào chưa từng thực hiện giao dịch
select ac_no, ac_balance from account 
where Ac_no not in (select distinct Ac_no from transactions)

--21.	Ai là người cùng chi nhánh với Trần Văn Thiện Thanh
select Cust_name, Cust_ad, BR_name from customer inner join Branch on customer.Br_id=Branch.BR_id
where Branch.Br_id = (select Branch.BR_id from customer inner join Branch on customer.Br_id=Branch.BR_id
					  where Cust_name = N'Trần Văn Thiện Thanh')
and Cust_name <> N'Trần Văn Thiện Thanh'