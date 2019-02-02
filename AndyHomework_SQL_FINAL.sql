Use sakila;

#Display the first and last names of all actors from the table actor
select first_name, last_name from actor;

#Display the first and last name of each actor in a single column in upper case letters. 
#Name the column Actor Nam
select UPPER(concat(first_name,' ',last_name)) as Actor_Name from actor;

#Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

#Find all actors whose last name contain the letters GEN:
select *
from actor
where last_name like '%GEN%';

#Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by last_name, first_name;

#Using IN, display the country_id and country columns of the following countries:
#Afghanistan, Bangladesh, and China:
select * 
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#You want to keep a description of each actor. You don't think you will be performing queries on a description, so 
#create a column in the table actor named description and use the data type
##BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
Add description BLOB;

#Remove description
alter table actor
drop description;

#List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'count' from actor
group by last_name;

#List last names of actors and the number of actors who have that last name, but 
#only for names that are shared by at least two actors
select last_name, count(*) as 'count' from actor
group by last_name
having count(*)>1;


#The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
UPDATE actor
SET first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

#Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
Update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

#You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address
SELECT first_name, last_name, a.address, a.address2, a.district, a.city_id, a.postal_code
FROM staff s
LEFT OUTER JOIN address a
ON s.address_id = a.address_id;

#Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
SELECT first_name, last_name, Sum(amount) as total_amount
FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
WHERE year(payment_date) = 2005
AND month(payment_date) = 8
GROUP BY first_name, last_name;


#List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT title, Count(*) as total_actor
FROM film f
INNER JOIN film_actor b
ON f.film_id = b.film_id
GROUP BY title;

#How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id) as film_count 
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE title='Hunchback Impossible';

#Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT c.customer_id, first_name, last_name, SUM(amount) as total_payment 
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY last_name;

#The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM (SELECT film_id, title, l.name as language 
FROM film f
LEFT OUTER JOIN language l
ON f.language_id = l.language_id
WHERE f.title LIKE 'K%'
OR f.title LIKE 'Q%') all_films;


#Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM actor
WHERE actor_id IN (
SELECT fa.actor_id 
FROM film_actor fa
JOIN film f
ON fa.film_id = f.film_id
WHERE f.title = 'Alone Trip');


#You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
#all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email, co.country 
FROM customer c
JOIN store s
ON c.store_id = s.store_id
JOIN address a
ON s.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id
JOIN country co
ON ct.country_id = co.country_id
WHERE co.country = 'Canada';

#Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT f.title, c.name AS movie_category FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

#Display the most frequently rented movies in descending order.
SELECT f.title AS movie_title, COUNT(r.rental_id) AS rental_count
FROM rental r
JOIN inventory i 
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rental_count desc;

#Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) AS Gross_amount
FROM payment AS p
JOIN rental AS r
USING(rental_id)
JOIN inventory i
USING(inventory_id)
JOIN store s
USING(store_id)
GROUP BY s.store_id;

#Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a 
ON s.address_id = a.address_id
JOIN city c
ON a.city_id = c.city_id
JOIN country co
ON c.country_id = co.country_id;

#List the top five genres in gross revenue in descending order.
SELECT c.name as genre, SUM(p.amount) gross_revenue 
FROM film_category fc
JOIN category c 
USING(category_id)
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY genre
ORDER BY gross_revenue desc
LIMIT 5 OFFSET 0;

#In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
#by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top5_Genres AS (
select c.name as genre, sum(p.amount) gross_revenue 
from film_category fc
join category c 
using(category_id)
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by genre
order by gross_revenue desc
LIMIT 5);

#How would you display the view that you created in 8a?
SELECT * FROM Top5_Genres;

#You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top5_Genres;