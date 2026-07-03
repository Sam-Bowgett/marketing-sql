--- table creation ---

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT CHECK (age > 0),
    region VARCHAR(100),
    income_bracket VARCHAR(50),
    customer_since DATE DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category VARCHAR(50),
    typical_revenue DECIMAL(10,2) CHECK (typical_revenue >= 0)
);

CREATE TABLE campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(50) NOT NULL,
    product_id INT REFERENCES products(product_id),
    channel VARCHAR(50),
    start_date DATE,
    end_date DATE,
    cost DECIMAL(10,2) CHECK (cost >= 0),
    CHECK (end_date >= start_date)
);

CREATE TABLE campaign_contacts (
    contact_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    campaign_id INT REFERENCES campaigns(campaign_id),
    contact_date DATE,
    opened BOOLEAN DEFAULT FALSE,
    clicked BOOLEAN DEFAULT FALSE,
    responded BOOLEAN DEFAULT FALSE
);

CREATE TABLE conversions (
    conversion_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    campaign_id INT REFERENCES campaigns(campaign_id),
    product_id INT REFERENCES products(product_id),
    conversion_date DATE,
    revenue DECIMAL(10,2) CHECK (revenue >= 0)
);


--- inserting table information ---

INSERT INTO products (product_name, category, typical_revenue)
VALUES 
	('Credit Card', 'Retail Banking', 850.00),
	('Personal Loan', 'Retail Banking', 1200.00),
	('Term Deposit', 'Retail Banking', 950.00),
	('Home Loan Refinance', 'Mortgage', 3200.00);


--- generating information and importing data ---

SELECT * FROM products;


SELECT * FROM customers LIMIT 10;


SELECT * FROM campaigns LIMIT 10;


SELECT * FROM campaign_contacts LIMIT 10;


SELECT * FROM conversions LIMIT 10;


--- test data count ---

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL
SELECT 'campaign_contacts', COUNT(*) FROM campaign_contacts
UNION ALL
SELECT 'conversions', COUNT(*) FROM conversions;


--- basic queries ---

SELECT 
	region,
	COUNT(customer_id) AS customer_count
FROM customers 
GROUP BY region
ORDER BY customer_count DESC;


SELECT 
	p.product_name,
	SUM(c.revenue) as total_revenue
FROM products AS p
INNER JOIN conversions AS c
	ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;


SELECT
	camp.campaign_name,
	COUNT(conv.conversion_id) AS conversion_count
FROM campaigns AS camp
INNER JOIN conversions AS conv
	ON camp.campaign_id = conv.campaign_id
GROUP BY camp.campaign_name
ORDER BY conversion_count DESC;


--- intermediate queries ---

WITH conversion_stats AS (
    SELECT
        camp.channel,
        COUNT(DISTINCT cc.contact_id) AS contact_count,
        COUNT(DISTINCT conv.conversion_id) AS conversion_count
    FROM campaigns AS camp
    INNER JOIN campaign_contacts AS cc
        ON camp.campaign_id = cc.campaign_id
    LEFT JOIN conversions AS conv
        ON cc.customer_id = conv.customer_id
        AND cc.campaign_id = conv.campaign_id
    GROUP BY camp.channel
)
SELECT
    channel,
    ROUND(conversion_count * 100.0 / contact_count, 2) AS conversion_rate
FROM conversion_stats;




SELECT
	cust.first_name,
	cust.last_name,
	COUNT(conv.conversion_id) AS conversion_count
FROM customers AS cust
INNER JOIN conversions AS conv
	ON cust.customer_id = conv.customer_id
GROUP BY 
	cust.first_name,
	cust.last_name
HAVING COUNT(conv.conversion_id) > 1
ORDER BY conversion_count DESC;




SELECT 
	p.product_name,
	ROUND(AVG(c.revenue),2) as avg_revenue
FROM products AS p
INNER JOIN conversions AS c
	ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY avg_revenue DESC;


--- advanced queries ---


WITH campaign_stats AS (
	SELECT
		camp.campaign_name,
		MAX(camp.cost) AS total_cost,
		SUM(conv.revenue) AS total_revenue
	FROM campaigns AS camp
	INNER JOIN conversions AS conv
		ON camp.campaign_id = conv.campaign_id
	GROUP BY camp.campaign_name
)
SELECT
	campaign_name,
	total_cost,
	total_revenue,
	ROUND(total_revenue * 100.0/total_cost, 2) AS roi
FROM campaign_stats;




WITH campaign_stats AS (
	SELECT
		camp.campaign_name,
		SUM(conv.revenue) AS total_revenue
	FROM campaigns AS camp
	INNER JOIN conversions AS conv
		ON camp.campaign_id = conv.campaign_id
	GROUP BY camp.campaign_name
)
SELECT
	campaign_name,
	total_revenue,
	RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM campaign_stats;



WITH conversion_stats AS (
    SELECT
        camp.campaign_id,
        camp.campaign_name,
        COUNT(DISTINCT cc.contact_id) AS contact_count,
        COUNT(DISTINCT conv.conversion_id) AS conversion_count
    FROM campaigns AS camp
    INNER JOIN campaign_contacts AS cc
        ON camp.campaign_id = cc.campaign_id
    LEFT JOIN conversions AS conv
        ON cc.customer_id = conv.customer_id
        AND cc.campaign_id = conv.campaign_id
    GROUP BY camp.campaign_id, camp.campaign_name
)
SELECT
    campaign_name,
    contact_count,
    conversion_count,
    ROUND(conversion_count * 100.0 / contact_count, 2) AS conversion_rate
FROM conversion_stats;



WITH revenue_stats AS (
	SELECT
		cust.region,
		cust.income_bracket,
		ROUND(AVG(conv.revenue),2) AS avg_revenue,
		RANK() OVER (PARTITION BY cust.region ORDER BY AVG(conv.revenue) DESC) AS revenue_rank
	FROM customers AS cust
	INNER JOIN conversions AS conv
		ON cust.customer_id = conv.customer_id
	GROUP BY 
		cust.region,
		cust.income_bracket
)

SELECT
	region,
	income_bracket,
	avg_revenue,
	revenue_rank,
	CASE 
		WHEN revenue_rank = 1 THEN 'High'
		WHEN revenue_rank = 2 THEN 'Medium'
		ELSE 'Low'
	END AS segment_rank
FROM revenue_stats;

