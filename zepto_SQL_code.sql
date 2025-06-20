DROP TABLE if exists zepto;

--- create table based on our columns in the dataset to extract the data from import procedure

CREATE TABLE zepto(
s_id SERIAL PRIMARY KEY,
category VARCHAR(200),
name VARCHAR(200) NOT NULL,
mrp NUMERIC(10,2),
discountPercent NUMERIC(10,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(10,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

--- structure of the table

SELECT * from zepto;

-- DATA EXPLORATION

-- count number of rows

SELECT COUNT(*) 
from zepto;

-- sample data

SELECT * FROM zepto
LIMIT 10;

-- null values

SELECT * FROM zepto
WHERE category IS NULL
OR name IS NULL
OR mrp IS NULL
OR discountPercent IS NULL
OR availableQuantity IS NULL
OR discountedSellingPrice IS NULL
OR weightInGms IS NULL
OR outOfStock IS NULL
OR quantity IS NULL;


-- different product categories

SELECT DISTINCT category
FROM zepto;

-- products in stock vs not in stock
SELECT outOfStock,COUNT(outOfStock)
FROM zepto
GROUP BY outOfStock;

-- product names with multiple time

SELECT DISTINCT name, COUNT(name) as "No of times repeated"
FROM zepto
GROUP BY name
ORDER BY COUNT(name) DESC;

-- DATA CLEANING

-- products with zero

SELECT * FROM zepto
WHERE mrp=0 or discountedSellingPrice =0;

DELETE FROM zepto 
WHERE s_id=3607;

-- convert paisa to ruppes

UPDATE zepto 
SET mrp=mrp/100.0
discountedSellingPrice=discountedSellingPrice/100.0;

SELECT mrp,discountedSellingPrice FROM zepto;

-- Q1. Find the top 10 best-value products based on the discount percentage.

SELECT DISTINCT name, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2.What are the Products with High MRP but Out of Stock

SELECT DISTINCT name,mrp,outOfStock
FROM zepto
WHERE mrp>300 AND outOfStock=true
ORDER BY mrp DESC;

-- Q3.Calculate Estimated Revenue for each category


SELECT category,
sum(discountedSellingPrice*quantity) AS Revenue
FROM zepto
GROUP BY category
ORDER BY Revenue DESC;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.

SELECT name,mrp,discountPercent
FROM zepto
WHERE mrp>500 and discountPercent<10;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.

SELECT category,ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;


-- Q6. Find the price per gram for products above 100g and sort by best value.

SELECT DISTINCT name,weightInGms,discountedSellingPrice, ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms>=100
ORDER BY price_per_gram ;

-- Q7.Group the products into categories like Low, Medium, Bulk.

SELECT DISTINCT category,
CASE
   WHEN quantity < 213 THEN 'Low'
   WHEN quantity <= 900 THEN 'Medium'
   WHEN quantity > 900 THEN 'Bulk'
END AS nature
from zepto;


-- Q8.What is the Total Inventory Weight Per Category 

SELECT category,ROUND(SUM(quantity * weightInGms)/1000.0,2) as Total_inventory
from zepto
GROUP BY category;

-- Q9:Find all products whose discountPercent is greater than the average discountPercent across the entire table.

SELECT category, discountPercent
FROM zepto
WHERE discountPercent > (
    SELECT AVG(discountPercent) FROM zepto
);

-- Q10.List the top 3 categories with the highest total availableQuantity.

SELECT category,SUM(availableQuantity) as Total_availableQuantity
FROM zepto 
GROUP BY category
ORDER BY Total_availableQuantity DESC
LIMIT 3;

-- Q11.List products whose discountedSellingPrice is less than 70% of their MRP.

SELECT DISTINCT name,mrp,discountedSellingPrice
FROM zepto
WHERE discountedSellingPrice <=0.7*mrp;

-- Q12.Find all categories where more than 5 products are out of stock.

SELECT category,COUNT(*) as total_no_of_outOfStock
FROM zepto
WHERE outOfStock=true
GROUP BY category
HAVING COUNT(*)>5;
