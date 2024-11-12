SELECT * 
FROM foodie_fi.plans;

SELECT * 
FROM foodie_fi.subs;

--How many customers has Foodie-Fi ever had?
SELECT COUNT(DIStinct "CUSTOMER_ID") AS CUST
FROM foodie_fi.subs;

--What is the monthly distribution of trial plan start_date values for our dataset 
--use the start of the month as the group by value
SELECT DATE_TRUNC('month', "START_DATE")::DATE AS month_start,
       COUNT(*) AS trial_count
FROM foodie_fi.plans AS p
JOIN foodie_fi.subs AS s ON p."PLAN_ID" = s."PLAN_ID"
WHERE p."PLAN_NAME" = 'trial' 
GROUP BY month_start
ORDER BY month_start;

--What plan start_date values occur after the year 2020 for our dataset?
--Show the breakdown by count of events for each plan_name

SELECT "PLAN_NAME",
	p."PLAN_ID",
	COUNT(*) AS event_count
FROM foodie_fi.plans AS p
JOIN foodie_fi.subs AS s ON p."PLAN_ID" = s."PLAN_ID"
WHERE EXTRACT(YEAR FROM s."START_DATE") > 2020
group by "PLAN_NAME", p."PLAN_ID"
ORDER BY p."PLAN_ID";

--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

-- churned customers
SELECT 
COUNT(DISTINCT "CUSTOMER_ID") as churned_customers
FROM foodie_fi.subs 
WHERE "PLAN_ID" = 4;

-- total customers and churned customers
SELECT 
COUNT(DISTINCT "CUSTOMER_ID") as churned_customers,
	(SELECT COUNT(DISTINCT "CUSTOMER_ID") 
	FROM foodie_fi.subs ) as total_customers 
FROM  foodie_fi.subs
WHERE "PLAN_ID" = 4;


SELECT 
    COUNT(DISTINCT "CUSTOMER_ID") AS customer_count,
    ROUND((COUNT(DISTINCT "CUSTOMER_ID")::NUMERIC / (SELECT COUNT(DISTINCT s."CUSTOMER_ID") FROM foodie_fi.subs AS s)) * 100, 1) AS churn_percentage
FROM  foodie_fi.subs
WHERE   "PLAN_ID" = 4;


--How many customers have churned straight after their initial free trial 
--what percentage is this rounded to the nearest whole number?

WITH CTE as (
SELECT "CUSTOMER_ID",
	"PLAN_NAME",
	ROW_NUMBER() OVER(PARTITION BY "CUSTOMER_ID" ORDER BY "START_DATE" ASC) as rn
FROM foodie_fi.subs AS s
INNER JOIN foodie_fi.plans AS p ON p."PLAN_ID" = s."PLAN_ID"
	)
SELECT  COUNT(DISTINCT "CUSTOMER_ID") AS churned_after_trial_customers,
    ROUND( (COUNT(DISTINCT "CUSTOMER_ID")::NUMERIC /  (SELECT COUNT(DISTINCT "CUSTOMER_ID") FROM foodie_fi.subs)) * 100, 0) AS percent_churn_after_trial
FROM CTE
WHERE   rn = 2  -- Filter to customers who churned after the trial period
    AND "PLAN_NAME" = 'churn'; 




-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH CTE as (
SELECT "CUSTOMER_ID",
	"PLAN_NAME",
	ROW_NUMBER() OVER(PARTITION BY "CUSTOMER_ID" ORDER BY "START_DATE" ASC) as rn
FROM foodie_fi.subs AS s
INNER JOIN foodie_fi.plans AS p ON p."PLAN_ID" = s."PLAN_ID"
	)
SELECT "PLAN_NAME",
COUNT("CUSTOMER_ID") as customer_count,
	  ROUND( (COUNT(DISTINCT "CUSTOMER_ID")::NUMERIC /  (SELECT COUNT(DISTINCT "CUSTOMER_ID") FROM CTE)) *100,1) as customer_percent
FROM CTE
WHERE rn = 2
GROUP BY "PLAN_NAME";

--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH CTE as (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY "CUSTOMER_ID" ORDER BY "START_DATE" DESC) AS rn
FROM foodie_fi.subs 
WHERE "START_DATE" <='2020-12-31'
	)
SELECT "PLAN_NAME",
COUNT("CUSTOMER_ID") as customer_count,
	  ROUND( (COUNT(DISTINCT "CUSTOMER_ID")::NUMERIC /  (SELECT COUNT(DISTINCT "CUSTOMER_ID") FROM CTE)) *100,1) as customer_percent
FROM CTE
INNER JOIN foodie_fi.plans AS p ON CTE."PLAN_ID" = p."PLAN_ID"
WHERE rn=1
GROUP BY "PLAN_NAME";

--How many customers have upgraded to an annual plan in 2020?

SELECT COUNT("CUSTOMER_ID") AS Annual_Customers
FROM foodie_fi.subs AS s
INNER JOIN foodie_fi.plans AS p ON p."PLAN_ID" = s."PLAN_ID"
WHERE EXTRACT(YEAR FROM s."START_DATE") = 2020
	AND "PLAN_NAME" = 'pro annual'; 

--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH TRIAL AS (
SELECT "CUSTOMER_ID",
	"START_DATE" AS trial_start
FROM foodie_fi.subs
WHERE "PLAN_ID"=0
)
, ANNUAL AS (
	SELECT "CUSTOMER_ID",
	"START_DATE" AS annual_start
	FROM foodie_fi.subs
	WHERE "PLAN_ID"= 3
)
SELECT  ROUND(AVG(EXTRACT(DAY FROM annual_start - trial_start)), 0) AS average_days_from_trial_to_annual
FROM TRIAL AS T
INNER JOIN ANNUAL AS A ON T."CUSTOMER_ID" = A."CUSTOMER_ID";

--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH TRIAL AS (
SELECT "CUSTOMER_ID",
	"START_DATE" AS trial_start
FROM foodie_fi.subs
WHERE "PLAN_ID"=0
)
, ANNUAL AS (
	SELECT "CUSTOMER_ID",
	"START_DATE" AS annual_start
	FROM foodie_fi.subs
	WHERE "PLAN_ID"= 3
)
SELECT  
   CASE
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 91 AND 120 THEN '91-120 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 121 AND 150 THEN '121-150 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 151 AND 180 THEN '151-180 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 181 AND 210 THEN '181-210 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 211 AND 240 THEN '211-240 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 241 AND 270 THEN '241-270 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 271 AND 300 THEN '271-300 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 301 AND 330 THEN '301-330 days'
        WHEN EXTRACT(DAY FROM annual_start - trial_start) BETWEEN 331 AND 360 THEN '331-360 days'
        ELSE '361+ days'
    END AS days_range,
    COUNT(*) AS customer_count
FROM TRIAL AS T
INNER JOIN ANNUAL AS A ON T."CUSTOMER_ID" = A."CUSTOMER_ID"
GROUP BY  days_range
ORDER BY  days_range;


--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


WITH PRO_MON AS (
SELECT "CUSTOMER_ID",
	"START_DATE" AS PROMON_START
FROM foodie_fi.subs
WHERE "PLAN_ID"=2
)
, BAS_MON AS (
	SELECT "CUSTOMER_ID",
	"START_DATE" AS BASMON_start
	FROM foodie_fi.subs
	WHERE "PLAN_ID"= 1
)
SELECT P."CUSTOMER_ID",
	PROMON_START,
	BASMON_start
FROM PRO_MON AS P
INNER JOIN BAS_MON AS B ON P."CUSTOMER_ID" = B."CUSTOMER_ID"
WHERE PROMON_START < BASMON_start
AND EXTRACT(YEAR FROM BASMON_start) = 2020;

