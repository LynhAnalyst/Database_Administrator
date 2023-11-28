-- 1. Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
select MONTH(t_date) as 'Tháng', sum(t_amount) as 'Tổng tiền' from transactions
where DATEPART(year,t_date) = 2014
group by MONTH(t_date)

--2. Thống kê tổng tiền KH gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
select BR_name, sum(t_amount) as 'Tổng tiền'
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where t_type = 1
group by BR_name
order by sum(t_amount) DESC

--3. Những chi nhánh nào thực hiện nhiều giao dịch gửi tiền trong tháng 12/2015 hơn chi nhánh Đà Nẵng
select BR_name, count(t_id) as N'Tổng số giao dịch'
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where DATEPART(MONTH,t_date) = 12 and DATEPART(year,t_date) = 2015 and t_type = 1
group by BR_name
having count(t_id) <> (select count(t_id) 
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where DATEPART(MONTH,t_date) = 12 and DATEPART(year,t_date) = 2015 and t_type = 1 and BR_name like N'%Đà Nẵng')

--4. Hiển thị danh sách KH chưa thực hiện giao dịch nào trong năm 2017
select Cust_name, Cust_ad 
from customer left join account on customer.Cust_id = account.cust_id 
join transactions on account.Ac_no = transactions.ac_no
where account.Ac_no not in (select distinct Ac_no from transactions) 
and t_type = '' and datepart(year,t_date) = 2017

/*5. Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. Nếu có thể hãy đưa ra tên của người 
thực hiện giao dịch và chi nhánh*/
select top 1 Cust_name, BR_name, t_date, sum(t_amount) as 'Tổng tiền'
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where datepart(Q,t_date) = 4 and t_type = 1
group by Cust_name, BR_name, t_date
order by sum(t_amount) DESC

--6. Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
select count(*) from 
	(select Cust_name, count(distinct customer.Cust_id) 
	from customer join account on customer.Cust_id = account.cust_id
	where Cust_ad like N'%ĐĂK%LĂK' 
	group by Cust_name
	having count(account.Ac_no) > 1)

/*7. Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng để chuyển sang ngân hàng 
khác hoặc chuyển sang hình thức tiết kiệm khác. Hãy lọc những khách hàng có xu hướng rút tiền 
khỏi ngân hàng bằng cách hiển thị những người rút gần hết tiền trong tài khoản 
(tổng tiền rút trong tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)*/
select customer.Cust_id, Cust_name, sum(t_amount) as N'Tổng tiền rút', ac_balance as N'Số dư'
from customer join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where DATEPART(m,t_date) = 12 and DATEPART(y,t_date) = 2017 and t_type = 0
group by customer.Cust_id, Cust_name, ac_balance
having sum(t_amount) > 100000000 and ac_balance <= 100000

/*8. Hãy liệt kê những tài khoản bất thường đó. 
Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản*/
select account.ac_no, ac_balance, 
(sum(case when t_type = 1 then t_amount else 0 end) - sum(case when t_type = 0 then t_amount else 0 end)) as 'Số dư TK'
from transactions right join account on transactions.ac_no = account.Ac_no
group by account.ac_no, ac_balance
having (sum(case when t_type = 1 then t_amount else 0 end) - sum(case when t_type = 0 then t_amount else 0 end)) <> ac_balance

/*9. Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị 
chuyển tiền tới. Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày 
(chỉ xét những giao dịch diễn ra trong buổi chiều), sắp xếp giảm giần theo lượng tiền giao dịch. */
select BR_name, avg(t_amount) as N'Lượng tiền trung bình theo ngày', day(t_date) as N'Ngày'
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where t_type = 0 and (t_time between '13:00' and '18:00')
group by BR_name, day(t_date)
order by avg(t_amount) DESC

/*10.	Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. 
Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; 
chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT.*/
select t_id, Branch.Br_id, BR_name, t_date
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where DATEPART(q,t_date) = 1 and Branch.Br_id like 'VT%'

/*11. Ông Phạm Duy Khánh thuộc chi nhánh nào? Từ 01/2017 đến nay ông Khánh đã thực hiện 
bao nhiêu giao dịch gửi tiền vào ngân hàng với tổng số tiền là bao nhiêu.*/
select BR_name, count(t_id) as N'Số giao dịch', sum(t_amount) as N'Tổng số tiền'
from Branch join customer on Branch.BR_id = customer.Br_id
join account on customer.Cust_id = account.cust_id
join transactions on account.Ac_no = transactions.ac_no
where Cust_name = N'Phạm Duy Khánh' and datepart(m,t_date) = 1 and datepart(y,t_date) = 2017 and t_type = 1
group by BR_name

--12. Hiển thị khách hàng cùng họ với khách hàng có mã số 000002
select Cust_id, Cust_name from customer
where (left(Cust_name, CHARINDEX(' ',Cust_name))) = (select left(Cust_name, CHARINDEX(' ',Cust_name)) 
from customer where Cust_id = 000002)

--13. Hiển thị những khách hàng sống cùng tỉnh/thành phố với ông Lương Minh Hiếu
select Cust_name, Cust_ad from customer 
where Cust_ad like
(select ltrim(rtrim(iif(CHARINDEX(',', REVERSE(Cust_ad)) > 0,
		iif(len(RIGHT(Cust_ad,CHARINDEX(',', REVERSE(cust_ad))-1)) < 20,
		right(Cust_ad,CHARINDEX(',', REVERSE(cust_ad))-1),RIGHT(Cust_ad, CHARINDEX(' ',REVERSE(cust_ad),7)-1)),
		right(Cust_ad,CHARINDEX('-', REVERSE(cust_ad))-1)))) as N'Tỉnh/TP'
from customer
where Cust_name = N'Lương Minh Hiếu')












