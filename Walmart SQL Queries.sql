SELECT * FROM walmart;

-- SECTION 1️: BASIC DATA UNDERSTANDING
-- --------------------------------------

-- 1.1 Total number of transactions
SELECT COUNT(*) AS total_transactions FROM walmart;

-- 1.2 View first 5 rows of data
SELECT * FROM walmart LIMIT 5;

-- 1.3 Unique branches, cities, and categories
SELECT COUNT(DISTINCT branch) AS total_branches,
       COUNT(DISTINCT city) AS total_cities,
       COUNT(DISTINCT category) AS total_categories
FROM walmart;

-- 1.4 Maximum and minimum quantity sold
SELECT MAX(quantity) AS max_quantity, MIN(quantity) AS min_quantity FROM walmart;


-- SECTION 2️: CUSTOMER & PAYMENT INSIGHTS
-- ------------------------------------------

-- 2.1 Count of transactions and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS num_transactions,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity_sold DESC;

-- 2.2 Most preferred payment method per branch
WITH payment_ranking AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS transaction_count,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT * FROM payment_ranking WHERE rank = 1;


-- SECTION 3️: PRODUCT CATEGORY & PROFIT ANALYSIS
-- -----------------------------------------------

-- 3.1 Revenue and profit by category
SELECT 
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- 3.2 Average, min, max rating per city-category pair
SELECT 
    city,
    category,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY avg_rating DESC;

-- 3.3 Highest-rated product category per branch
WITH category_rating AS (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
)
SELECT * FROM category_rating WHERE rank = 1;

-- 3.4 Category share in total revenue
SELECT 
    category,
    ROUND((SUM(total) * 100.0 / (SELECT SUM(total) FROM walmart))::numeric, 2) AS category_percent
FROM walmart
GROUP BY category
ORDER BY category_percent DESC;


-- SECTION 4️: TIME-BASED SALES TRENDS
-- --------------------------------------

-- 4.1 Sales by day of the week
SELECT 
    weekday,
    COUNT(*) AS num_transactions,
    SUM(total) AS revenue
FROM walmart
GROUP BY weekday
ORDER BY revenue DESC;


-- 4.2 Sales by hour
SELECT 
    hour,
    COUNT(*) AS num_transactions,
    SUM(total) AS revenue
FROM walmart
GROUP BY hour
ORDER BY hour;


-- 4.3 Sales by shift (Morning, Afternoon, Evening)
SELECT
    branch,
    shift,
    COUNT(*) AS num_transactions
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_transactions DESC;


-- 4.4 Month-over-month revenue trend
SELECT 
    year,
    month,
    SUM(total) AS revenue
FROM walmart
GROUP BY year, month
ORDER BY year, month;


-- SECTION 5️: ADVANCED KPIs & STRATEGIC INSIGHTS
-- -----------------------------------------------

-- 5.1 Busiest day (most transactions) for each branch
WITH daily_rank AS (
    SELECT 
        branch,
        weekday AS day_of_week,
        COUNT(*) AS num_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, weekday
)
SELECT * FROM daily_rank WHERE rank = 1;


-- 5.2 5 branches with revenue decrease from 2022 to 2023
WITH rev_2022 AS (
    SELECT branch, SUM(total) AS revenue_2022
    FROM walmart
    WHERE year = 2022
    GROUP BY branch
),
rev_2023 AS (
    SELECT branch, SUM(total) AS revenue_2023
    FROM walmart
    WHERE year = 2023
    GROUP BY branch
)
SELECT 
    rev_2022.branch,
    rev_2022.revenue_2022,
    rev_2023.revenue_2023,
    ROUND(
        ((rev_2022.revenue_2022 - rev_2023.revenue_2023) / rev_2022.revenue_2022)::numeric,
        2
    ) * 100 AS decline_pct
FROM rev_2022
JOIN rev_2023 ON rev_2022.branch = rev_2023.branch
WHERE rev_2023.revenue_2023 < rev_2022.revenue_2022
ORDER BY decline_pct DESC
LIMIT 5;


-- 5.3 Average basket value
SELECT 
    AVG(total) AS avg_basket_value
FROM walmart;


-- 5.4 Segmenting customers by purchase value
SELECT 
    CASE 
        WHEN total < 100 THEN 'Low'
        WHEN total BETWEEN 100 AND 300 THEN 'Medium'
        ELSE 'High'
    END AS customer_segment,
    COUNT(*) AS num_customers,
    SUM(total) AS revenue
FROM walmart
GROUP BY customer_segment
ORDER BY revenue DESC;


-- 5.5 Most common invoice value range (rounded)
SELECT 
    ROUND(total::numeric, -1) AS rounded_total,
    COUNT(*) AS freq
FROM walmart
GROUP BY rounded_total
ORDER BY freq DESC
LIMIT 5;

-- 5.6 City-wise average profit margin
SELECT 
    city,
    ROUND(AVG(profit_margin) * 100, 2) AS avg_profit_percent
FROM walmart
GROUP BY city
ORDER BY avg_profit_percent DESC;


-- 5.6 City-wise average profit margin
SELECT 
    city,
    ROUND((AVG(profit_margin) * 100)::numeric, 2) AS avg_profit_percent
FROM walmart
GROUP BY city
ORDER BY avg_profit_percent DESC;