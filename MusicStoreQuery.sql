-- SET_1_QUESTIONS
select * from employee order by levels desc limit 1;
select * from employee where levels = (select max(levels) from employee order by levels desc);
--
select count(*) as cnt, billing_country from invoice
group by billing_country
order by cnt desc;
--
select total from invoice order by total desc limit 3;
--
select billing_city,sum(total) as total_sum from invoice
group by billing_city
order by total_sum desc limit 1;
--
select * from customer;
select * from invoice;

select customer_id, sum(total) as total_sum from invoice
where customer_id in (select customer_id from customer)
group by customer_id
order by total_sum desc limit 1;

-- SET_2_QUESTIONS
select distinct customer.first_name,customer.last_name,customer.email, genre.name 
from customer join invoice 
using(customer_id) join invoice_line
using(invoice_id) join track
using(track_id) join genre
using(genre_id)
where genre.name='ROCK'
order by customer.email ASC;
--
select artist.name,count(artist_id) as total_count
from artist join album
using(artist_id) join track
using(album_id) join genre
using(genre_id)
where genre.name ='ROCK'
group by 1
order by total_count desc
limit 10;
--
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- SET_3_QUESTIONS
WITH cte as (select artist.artist_id AS art_id,
artist.name,sum(invoice_line.unit_price*invoice_line.quantity) as total_spent
from invoice join invoice_line
using(invoice_id) join track
using(track_id) join album
using(album_id) join artist
using(artist_id)
group by 1,2
order by total_spent desc limit 1)

select distinct concat(customer.first_name,' ',customer.last_name) as cust_name,customer.customer_id,
cte.name,sum(invLine.unit_price*invLine.quantity) as total_amount_spent
from customer join invoice
using(customer_id) join invoice_line invLine
on invoice.invoice_id=invLine.invoice_id join track
using(track_id) join album
using(album_id) join cte
on album.artist_id=cte.art_id
group by 1,2,3
order by total_amount_spent desc;
--
WITH cte AS (select customer.country, 
genre.name,
count(invoice_line.quantity) as total_purchase, 
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rn
from customer join invoice 
using(customer_id) join invoice_line
using(invoice_id) join track
using(track_id) join genre
using(genre_id)
group by 1,2
order by 1 asc, 3 desc
)
select * from cte where rn=1;
--
WITH cte as (select customer.customer_id,concat(customer.first_name,' ',customer.last_name) as cust_name,
invoice.billing_country,sum(invoice.total) as total_spent,
row_number() over(partition by invoice.billing_country order by sum(invoice.total) desc) as rn
from customer join invoice
using(customer_id) 
group by 1,2,3
order by 3 asc, 4 desc)
select * from cte where rn=1;