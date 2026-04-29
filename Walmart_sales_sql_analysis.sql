-- Walmart Project Queries

select * from walmart_sales ws

select count(*) from walmart_sales ws

-- Business Problems
-- Q1 Find different payment method and number of transactions, number of quantity sold

select 
	payment_method, 
	count(*) as no_of_transactions, 
	sum(quantity) as total_quantity_sold 
from walmart_sales ws 
group by payment_method

-- Q2 Identify the highest-rated category in each branch, displaying the branch, category, AVG RATING
 

WITH ranked_data AS (
    SELECT 
        ws."Branch", 
        ws.category, 
        ROUND(AVG(rating)::numeric, 2) AS average_rating,
        RANK() OVER (
            PARTITION BY ws."Branch" 
            ORDER BY AVG(rating) DESC
        ) AS rank
    FROM walmart_sales ws 
    GROUP BY ws."Branch", ws.category
)
SELECT *
FROM ranked_data
WHERE rank = 1

-- Q3 Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM
	(SELECT 
		"Branch",
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) as rank
	from walmart_sales ws
	GROUP BY 1, 2
	)
WHERE rank = 1

-- Q4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

select 
	payment_method, 
	sum(quantity) as total_quantity_of_items
from walmart_sales ws 
group by payment_method
order by total_quantity_of_items desc


-- Q5 Determine the average, minimum and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

select 
	"City", 
	round(avg(rating)::numeric, 2) as avg_rating_per_city,
	min(rating) as lowest_rating_per_city,
	max(rating) as highest_rating_per_city
from walmart_sales ws 
group by "City"

-- Q6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM("Total") as total_revenue,
	SUM("Total" * profit_margin) as profit
FROM walmart_sales ws 
GROUP BY ws.category 

-- Q7 Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH most_common_payment_method 
AS
(SELECT 
	"Branch",
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) as rank
FROM walmart_sales ws
GROUP BY 1, 2 ---cardinal referencing
)
SELECT *
FROM most_common_payment_method 
WHERE rank = 1


-- Q8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	"Branch",
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 16 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart_sales ws
GROUP BY 1, 2 ---cardinal referencing
ORDER BY 1, 3 desc ---cardinal referencing

SELECT
	"Branch",
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 16 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart_sales ws
GROUP BY "Branch", day_time
ORDER BY "Branch", count(*) desc

-- Q9 Identify 5 branch with highest decrease ratio in revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart_sales ws

-- 2022 sales

WITH revenue_2022
as (
	SELECT 
		"Branch",
		SUM("Total") as revenue
	FROM walmart_sales ws
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	GROUP BY 1
),

revenue_2023
as (

	SELECT 
		"Branch",
		SUM("Total") as revenue
	FROM walmart_sales ws
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls."Branch",
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
join revenue_2023 as cs ON ls."Branch" = cs."Branch"
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

