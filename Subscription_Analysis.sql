use Idrishab;

SELECT * FROM Customers;
SELECT * FROM orders;
SELECT * FROM subscriptions;

ALTER TABLE customers
DROP COLUMN column4;

WITH sub_frequency AS (
	SELECT 
		o.customer_id, 
		COUNT(o.subscription_id) AS no_of_subs
	FROM orders o --use of alias "o" for orders table
	GROUP BY o.customer_id -- ensures subscription is counted per customer
	)

SELECT	
	monthly_totals.customer_id, 
	monthly_totals.customer_name,
	CASE
		WHEN sub_frequency.no_of_subs IS NULL THEN '0'
		ELSE sub_frequency.no_of_subs
	END sub_count,
	CASE 
		WHEN monthly_totals.total_sub_amount IS NULL THEN '0'
		ELSE monthly_totals.total_sub_amount
	END [total_sub_amount ($)]
FROM 
	(
	SELECT 
		c.customer_id, 
		c.customer_name, 
		sub_amount.total_sub_amount
	FROM 
		(
		-- aggregating the amount spent on subscription per customer
		SELECT o.customer_id, 
		SUM(s.price_per_month) AS total_sub_amount
		FROM orders o
		LEFT JOIN subscriptions s
		ON o.subscription_id = s.subscription_id
		GROUP BY o.customer_id
		) AS sub_amount
	RIGHT JOIN Customers c
	ON sub_amount.customer_id = c.customer_id
	) AS monthly_totals
LEFT JOIN sub_frequency
ON monthly_totals.customer_id = sub_frequency.customer_id;
GO