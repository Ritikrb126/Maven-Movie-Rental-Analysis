-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE MAVENMOVIES;

-- EDA

-- UNDERSTANDING SCHEMA

SELECT * FROM RENTAL;

SELECT * FROM INVENTORY;

SELECT * FROM CUSTOMER;

SELECT * FROM FILM;

-- 1) Rental Rate & Pricing Analysis
-- "How can we extract the first name, last name, and email address of all customers to prepare a comprehensive contact list for the marketing team?" --
SELECT 
	first_name,
    last_name,
    email
 FROM CUSTOMER;
 
-- "What is the total number of movies in the inventory that are available for rent at the lowest rental rate of $0.99?"--
SELECT  
	rental_rate,
    COUNT(*) AS Cheapest_rental
FROM film
WHERE rental_rate=0.99;

-- "What is the distribution of movies across different rental rate categories?" --
SELECT 
	rental_rate,
    COUNT(*) AS total_movies
FROM film
GROUP BY rental_rate;

-- "Do movies with higher replacement costs have higher rental rates?" --
SELECT 
	replacement_cost,
	COUNT(film_id) No_of_film,
    MAX(rental_rate) Max_rental,
    MIN(rental_rate) Mix_rental,
    AVG(rental_rate) AS Avg_rental
FROM film
GROUP BY replacement_cost
ORDER BY  replacement_cost DESC;
-- 2) Movie Ratings & Performance
-- "Which movie rating category has the highest number of films?"--
SELECT 
	rating,
    count(*) AS no_of_movies
FROM film
GROUP BY rating
ORDER BY no_of_movies DESC;

-- "What is the most common movie rating in each store?" --
SELECT 
	inv.store_id,
    f.rating,
    COUNT(*) total_films
FROM inventory AS inv LEFT JOIN film AS f ON inv.film_id=f.film_id
GROUP BY inv.store_id,f.rating
ORDER BY total_films DESC;

-- "How does movie length correlate with rental duration and ratings?"
SELECT rating,
	COUNT(film_id) AS No_of_films,
    MIN(length) AS Shortest_film,
    MAX(length) AS Longest_film,
	AVG(length) AS avg_length,
    AVG(rental_duration) AS rental_duration
FROM film 
GROUP BY rating
ORDER BY AVG(rental_duration) DESC;

-- 3) Movie Inventory & Availability
-- "Can we list all movies along with their category and language?"--
SELECT 
	f.title AS film_name,
	c.name AS category,
    l.name AS Language_mode
from film_category AS fc LEFT JOIN film f ON fc.film_id=f.film_id 
LEFT JOIN category AS c ON fc.category_id=c.category_id 
LEFT JOIN language AS  l ON f.language_id=l.language_id;

-- "How many times has each movie been rented out?" --
SELECT 
	f.title,
    COUNT(*) AS Popularity
FROM rental AS  r LEFT JOIN inventory i ON r.inventory_id=i.inventory_id 
LEFT JOIN film f ON i.film_id=f.film_id
GROUP BY f.title
ORDER BY Popularity DESC;

-- Can we pull a list of movies available in inventory , including title, description,film_id and store ID?"--
SELECT 
	f.title,
    f.description,
    i.store_id,
    i.inventory_id,
    i.film_id
FROM inventory AS i INNER JOIN film AS f ON i.film_id=f.film_id;

-- 4) Revenue & Business Performance
-- "What are the top 10 highest-grossing movies in terms of revenue?" --
SELECT 
	ft.title AS FILM_NAME,
    SUM(p.amount) AS Total_revenue
FROM rental AS r LEFT JOIN payment p on r.rental_id=p.rental_id
LEFT JOIN inventory AS i ON r.inventory_id=i.inventory_id
LEFT JOIN film_text AS ft ON i.film_id=ft.film_id
GROUP BY ft.title
ORDER BY Total_revenue DESC 
LIMIT 10;

-- "Which store has historically generated the most revenue? And How does it compare with other stores?"--
SELECT 
	s.store_id,
    SUM(amount) AS TotaL_revenue
FROM rental AS r LEFT JOIN payment p ON r.rental_id=p.rental_id
LEFT JOIN staff s ON p.staff_id=s.staff_id
GROUP BY s.store_id
ORDER BY TotaL_revenue;

-- "What are the peak rental months and trends over time?" --
SELECT 
	YEAR(rental_date) AS Year,
    MONTHNAME(rental_date) AS Month,
    COUNT(rental_id) as total_rented
FROM rental 
GROUP BY YEAR(rental_date),
    MONTHNAME(rental_date); 
-- other way to do it --
SELECT 
	EXTRACT(YEAR FROM rental_date) AS Year,
    EXTRACT(MONTH FROM rental_date) as Month,
    COUNT(rental_id) as Total_Rented
FROM rental 
GROUP BY EXTRACT(YEAR FROM rental_date) ,EXTRACT(MONTH FROM rental_date);

-- "Which customers have spent the most money on rentals?"--
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(amount) AS Spend_amount
FROM rental AS r LEFT JOIN payment AS p ON r.rental_id=p.rental_id
LEFT JOIN customer AS c ON p.customer_id=c.customer_id
GROUP BY c.customer_id
ORDER BY Spend_amount DESC
LIMIT 1;

-- 5) Customer Insights & Loyalty
-- "Who are the top customers who have rented at least 30 times?" --
SELECT 
	r.customer_id,
	c.first_name,
    c.last_name,
    c.email,
    a.phone
FROM rental r left join customer c ON r.customer_id = c.customer_id
LEFT JOIN address AS a ON c.address_id=a.address_id
GROUP BY r.customer_id
HAVING COUNT(rental_id)>30;
-- other way to do it --
SELECT 
	customer_id,
	first_name,
    last_name,
    email,
    phone
FROM  customer AS c LEFT JOIN address AS a ON c.address_id=a.address_id
WHERE customer_id IN (
SELECT r.customer_id 
FROM rental r 
GROUP BY r.customer_id
HAVING COUNT(rental_id)>30);
-- other way to do it --
SELECT c.customer_id,
	c.first_name,
    c.last_name,
    c.email
FROM (
SELECT customer_id
FROM rental 
GROUP BY customer_id
HAVING COUNT(rental_id)>30) AS lc INNER JOIN customer AS c ON lc.customer_id=c.customer_id;

-- "Could you pull all payments from our first 100 customers (based on customer ID)" --
SELECT * 
FROM payment
WHERE customer_id<=100;
-- "other way to do it" --
SELECT * 
FROM payment
WHERE customer_id BETWEEN 1 and 100;

-- "How many customers from first 100 have made payments over $5 since January 1, 2006?" --
SELECT 
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id BETWEEN 1 and 100
AND amount>5 
AND  DATE(payment_date)>= "2006-01-01";

-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?
SELECT  
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
where amount>5 AND customer_id IN (SELECT customer_id
FROM payment
WHERE customer_id BETWEEN 1 and 100
AND amount>5 
AND  DATE(payment_date)>= "2006-01-01");

-- "Can we identify customers who have rented less than 15 times overall?" --
SELECT 
	p.customer_id,
    c.first_name,
    c.last_name,
	c.email,
    count(rental_id) AS Rented_film
FROM payment AS p  LEFT JOIN customer AS c ON p.customer_id=c.customer_id
GROUP BY p.customer_id
HAVING rented_film<15
ORDER BY rented_film;

-- 6)Rental Trends & Behavioral Analysis
-- "Do longer movies also tend to be more expensive to rent?" --
SELECT 
	title,
    length,
    rental_rate
FROM film 
ORDER BY length DESC;

-- "How many titles are available, categorized by their respective rental durations?" --
SELECT 
	rental_duration,
    count(title) No_of_titles
FROM film
GROUP BY rental_duration
ORDER BY count(title)  DESC;

-- "Can we categorize movies by length for better recommendations?" --
SELECT 
	title,
	length,
	CASE 
    WHEN length<60 THEN 'Under 1 Hr'
    WHEN length BETWEEN 60 AND 90 THEN 'between 1 & 1.5'
    WHEN length >90 THEN 'over 1.5 Hr'
    ELSE 'error' END AS length_bucket
FROM film;

-- ""Which movies should be recommended to individuals based on specific demographics like cultural background or interests?""
SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;

-- 7)Special Features & Movie Extras
-- "How many films include the "Behind the Scenes" special feature?" --
SELECT 
	title,
    special_features
FROM film
WHERE LOWER(special_features) LIKE '%behind the scenes%';

-- 8)Staff & Store Management
-- "	• Can we list all staff members and advisors, and distinguish their roles?" --
SELECT 
	first_name,
    last_name,
    'Advisor'AS Designation 
FROM advisor 
UNION 
SELECT 
	first_name,
    last_name,
    'Staff Member' AS Desognation
from staff;

-- "Which store does each customer visit, and are they active or inactive?" --
SELECT 
	first_name,
	last_name,
	CASE 
		WHEN active=1 THEN  concat('store ',store_id,' ','active')
        ELSE CONCAT('store ',store_id,' ','inactive')
        END AS label
FROM customer;

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”
SELECT 
	DISTINCT f.title,f.description
FROM film AS f INNER JOIN inventory AS i on f.film_id=i.film_id
WHERE i.store_id=2;

-- 9)Actor & Casting Insights
-- "How many movies has each actor appeared in?" --
SELECT 
	a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(film_id) AS total_film
fROM actor AS a LEFT JOIN film_actor AS fa ON a.actor_id=fa.actor_id
GROUP BY a.actor_id
ORDER BY total_film DESC;

-- " Can we list all actors and the movies they have starred in?" --
SELECT 
	f.title,
    count(actor_id) AS total_actor
FROM film AS f LEFT JOIN film_actor AS fa ON f.film_id=fa.film_id
GROUP BY f.title
ORDER BY total_actor DESC;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
SELECT 
	a.actor_id,
    a.first_name,
    a.last_name,
    f.title
FROM actor AS a INNER JOIN film_actor AS fa ON a.actor_id=fa.actor_id
inner JOIN film AS f ON fa.film_id=f.film_id;


























