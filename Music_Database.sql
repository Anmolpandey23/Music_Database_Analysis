CREATE DATABASE TEST;
USE TEST;
CREATE TABLE CUSTOMER(
ID INT PRIMARY KEY,
NAME VARCHAR(50) NOT NULL,
Age INT NOT NULL
);

INSERT INTO CUSTOMER VALUES (1, "ANMOL PANDEY", 18);
INSERT INTO CUSTOMER VALUES (2, "AASHISH PANDEY", 16);

SELECT * FROM CUSTOMER;

SHOW TABLES;
ALTER TABLE CUSTOMER 
ADD COLUMN CITY CHAR(50) NOT NULL DEFAULT "PUNE";

INSERT INTO CUSTOMER (ID, NAME, AGE, CITY) VALUES (3, "ANMOL", 18,"PUNE");
INSERT INTO CUSTOMER (ID, NAME, AGE, CITY) VALUES (4, "AASHISH", 16,"MAHARASTRA");

UPDATE CUSTOMER 
SET CITY = "DELHI"
WHERE ID = 2;

SHOW COLUMNS FROM CUSTOMER;

WITH RECURSIVE my_CTE AS (
    SELECT 1 AS n   -- Base case: starts the recursion with 1
    UNION ALL
    SELECT n + 1    -- Recursive step: adds 1 to the previous value of n
    FROM my_CTE
    WHERE n < 3     -- Condition to stop recursion when n reaches 3
)
SELECT * FROM my_CTE;  -- Retrieves all values from the CTE


Create Database Music_Database;
use Music_Database;
-- Q1: Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most Invoices?

SELECT count(*), billing_country as c FROM invoice
Group by billing_country
ORDER BY c DESC;


-- Q3: What are top 3 values of total invoice

Select total from invoice
Order by total desc
limit 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals

Select Sum(total) as invoice_total , billing_city from invoice
Group by  billing_city 
Order by invoice_total desc;

-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that 
-- returns the person who has spent the most money.

SELECT 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    SUM(invoice.total) AS total
FROM 
    customer
JOIN 
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY 
    customer.customer_id, customer.first_name, customer.last_name
ORDER BY 
    total DESC
LIMIT 1;

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM 
customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice. invoice_id = invoice_line.invoice_id
Where track_id IN(
Select track_id From track
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre. name LIKE 'Rock'
)
ORDER BY email;

-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS Number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY Number_of_songs DESC
LIMIT 10;

-- Q8: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first.

Select name, milliseconds
From track
where milliseconds > (
    SELECT AVG(milliseconds) As average_track_length
    FROM track
)
ORDER BY milliseconds DESC;

-- Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
    SELECT artist.artist_id, artist.name AS artist_name, 
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sale
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album2 ON album2.album_id = track.album_id
    JOIN artist ON artist.artist_id = album2.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sale DESC
    LIMIT 1
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

-- Q10: We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres.

With popular_genre AS (
Select Count(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track. track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

-- Q11: Write a query that determines the customer that has spent the most on music for each country.
--  Write a query that returns the country along with the top customer and how much they spent. 
--  For countries where the top amount spent is shared, provide all customers who spent this amount

WITH customter_with_country AS (
SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 2,3 DESC),
country_max_spending AS(
SELECT billing_country, MAX(total_spending) AS max_spending
FROM customter_with_country
GROUP BY billing_country)
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms ON cc. billing_country = ms. billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

-- Second Method

With Customter_with_country AS (
Select customer. customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
FROM invoice
JOIN customer ON customer. customer_id = invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

