/*Q1: Who is the senior most employee based on job title?*/

SELECT * FROM employee
ORDER BY levels DESC,hire_date ASC
LIMIT 1;

/*Q2: Which country have the most invoices?*/

SELECT billing_country,COUNT(billing_country) AS no_of_invoice FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoice DESC
LIMIT 1;

/*Q3: What are top 3 values of total invoices?*/

SELECT total FROM invoice
ORDER BY total DESC;

/*Q4: Which city has the best customers?We would like to throw a promotional music festival in the city
we made the most money.Write a query thata returns one city  that has the highest sum of
invoice totals.Return both the city name and sum of all invoice totals.*/

select billing_city,sum(total) as invoice_total from invoice
group by billing_city
order by CITY DESC
limit 1;

/*Q5)Who is the best customer?the one who has spent the most*/

select x.customer_id,first_name,last_name,sum(total) as total_money
from customer as x
join invoice as y on x.customer_id=y.customer_id
group by x.customer_id
order by total_money desc
limit 1;

/*Write query to return the email,first name,last name and genre
of all rock music listeners .Return your list alphabetically by email starting with A*/

select distinct(c.email),c.first_name,c.last_name
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
where g.name like 'Rock'
order by c.email;

/*Let's invite the artist who have written the most rock musics in our dataset.Write a
query to return the artist name and total track count of top 10 rock bands*/

select a.name,count(t.track_id) as track_count
from artist as a
join album as al on a.artist_id=al.artist_id
join track as t on al.album_id=t.album_id
join genre as g on t.genre_id=g.genre_id
where g.name like 'Rock'
group by a.name
order by track_count desc
limit 10;

/*Return all the track names that have a song length longer than the average song
length.Return the name and milliseconds for each track.Order by the song length
with the longest songs listed first */

select name,milliseconds
from track
where milliseconds >(select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc;

/*Find how much amount spent by each customer on artis?Write a query to return
customer name ,artist name and total spent*/

with best_selling_artist as(
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on invoice_line.track_id=track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*quantity) as amount_spent
from invoice i
join customer as c on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id=il.track_id
join album as alb on alb.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/*We want to find out the most popular music genre for each country.
We determine the most popular genre as the genre with the highest
amount of purchases Write a query that returns each country along
with the top genre.For countries where the maximum number of
purchases is shared return all genres.*/

with popular_genre as(
select count(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity)desc)as rowno
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by 2,3,4
order by 2 asc,1 desc
)
select * from popular_genre where rowno <=1

/*Write aquery that determines the customer that has spent the most on music for each country.Write
a query that returns the country along with the top customer and how much they spent.For countries
where the top amount spent i shared,provide all customers who spent this amount.*/

WITH RECURSIVE customer_with_country AS (
SELECT customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,
SUM(invoice.total) AS total_spending
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
),
country_max_spending AS (SELECT billing_country,MAX(total_spending) AS max_spending
FROM customer_with_country
GROUP BY billing_country)
SELECT cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
FROM customer_with_country AS cc
JOIN country_max_spending AS ms ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;

