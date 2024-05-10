Use Sakila;
-- 1. Select the first name, last name, and email address of all the customers who have rented a movie.
select c.first_name, c.last_name, c.email
from sakila.customer c
join sakila.rental r
on c.customer_id = r.customer_id
-- where count(rent.rental_id) > 0 
group by c.first_name, c.last_name, c.email;

-- 2. What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made).
select c.customer_id, concat(c.last_name, ', ', c.first_name) as customer_name, avg(p.amount) as average_payment
from sakila.customer c
join sakila.payment p
on c.customer_id = p.customer_id
group by c.customer_id, c.last_name, c.first_name;

-- 3. Select the name and email address of all the customers who have rented the "Action" movies.

-- 3.1 Write the query using multiple join statements
select distinct concat(c.last_name, ', ', c.first_name) as customer_name, c.email
from sakila.customer c
join sakila.rental r
on c.customer_id = r.customer_id
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film_category f
on i.film_id = f.film_id
join sakila.category ca
on f.category_id = ca.category_id
where ca.name like 'Action'
order by customer_name;

-- 3.2 Write the query using sub queries with multiple WHERE clause and IN condition

-- First Step: Checking what is the category_id for "Action" category
select category_id from sakila.category
where name like 'Action'; -- category_id = 1

-- Second Step: Get all rentals of Action films
select * from sakila.rental r
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film_category f
on i.film_id = f.film_id
where f.category_id = (select category_id from sakila.category
						where name like 'Action');

-- Third Step: Get all customers who have rented
select distinct c.customer_id, concat(c.last_name, ', ', c.first_name) as customer_name, c.email
from sakila.customer c
join sakila.payment p
on c.customer_id = p.customer_id;

-- Final Step: Join all the previous subquerries to get all the customers who have rented 'Action' films
select distinct concat(c.last_name, ', ', c.first_name) as customer_name, c.email
from sakila.customer c
join sakila.rental r
on c.customer_id = r.customer_id
where c.customer_id in (select r.customer_id from sakila.rental r
							join sakila.inventory i
								on r.inventory_id = i.inventory_id
									join sakila.film_category f
										on i.film_id = f.film_id
											where f.category_id = (select category_id from sakila.category
													where name like 'Action')
							)
order by customer_name;

-- 3.3 Verify if the above two queries produce the same results or not
select count(*) as total_rows from (select distinct concat(c.last_name, ', ', c.first_name) as customer_name, c.email
									from sakila.customer c
									join sakila.rental r
									on c.customer_id = r.customer_id
									join sakila.inventory i
									on r.inventory_id = i.inventory_id
									join sakila.film_category f
									on i.film_id = f.film_id
									join sakila.category ca
									on f.category_id = ca.category_id
									where ca.name like 'Action'
									order by customer_name) as sub;
                                    
select count(*) as total_rows from (select distinct concat(c.last_name, ', ', c.first_name) as customer_name, c.email
									from sakila.customer c
									join sakila.rental r
									on c.customer_id = r.customer_id
									where c.customer_id in (select r.customer_id from sakila.rental r
																join sakila.inventory i
																on r.inventory_id = i.inventory_id
																join sakila.film_category f
																on i.film_id = f.film_id
																where f.category_id = (select category_id from sakila.category
																						where name like 'Action')
																)
									order by customer_name) as sub;
-- Yes, they do produce the same results

/* 4. Use the case statement to create a new column classifying existing 
--columns as either or high value transactions based on the amount of payment. 
If the amount is between 0 and 2, label should be low and 
--if the amount is between 2 and 4, the label should be medium, and if it is more than 4, then it should be high.*/

select * from sakila.payment;

select *, 
		case
			when amount between 0 and 2 then 'low'
            when amount between 2 and 4 then 'medium'
            else 'high'
		end as transaction_classification
from sakila.payment;