-- Create database
CREATE DATABASE dimensional_report_db;

USE dimensional_report_db;


-- Dimension table: Categories
CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);


-- Dimension table: Customers
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50)
);


-- Dimension table: Products
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);


-- Dimension table: Dates
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    month INT,
    month_name VARCHAR(20)
);


-- Fact table: Sales
CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    date_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);


-- Insert categories
INSERT INTO dim_category VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books');


-- Insert customers
INSERT INTO dim_customer VALUES
(1, 'Arun', 'Bengaluru'),
(2, 'Priya', 'Chennai'),
(3, 'Rahul', 'Mumbai'),
(4, 'Sneha', 'Hyderabad'),
(5, 'Kiran', 'Bengaluru');


-- Insert products
INSERT INTO dim_product VALUES
(101, 'Laptop', 1),
(102, 'Smartphone', 1),
(103, 'Headphones', 1),
(104, 'T-Shirt', 2),
(105, 'Jeans', 2),
(106, 'SQL Book', 3),
(107, 'Python Book', 3);


-- Insert dates
INSERT INTO dim_date VALUES
(1, '2025-01-10', 2025, 1, 'January'),
(2, '2025-01-15', 2025, 1, 'January'),
(3, '2025-02-05', 2025, 2, 'February'),
(4, '2025-02-18', 2025, 2, 'February'),
(5, '2025-03-03', 2025, 3, 'March'),
(6, '2025-03-20', 2025, 3, 'March'),
(7, '2025-04-08', 2025, 4, 'April'),
(8, '2025-04-25', 2025, 4, 'April');


-- Insert sales
INSERT INTO fact_sales VALUES
(1, 1, 1, 101, 2, 60000),
(2, 1, 2, 104, 3, 800),
(3, 2, 3, 102, 2, 45000),
(4, 2, 4, 106, 4, 600),
(5, 3, 1, 103, 5, 2000),
(6, 3, 5, 105, 2, 1800),
(7, 4, 2, 101, 1, 60000),
(8, 4, 3, 107, 5, 700),
(9, 5, 4, 102, 3, 45000),
(10, 5, 5, 104, 4, 800),
(11, 6, 1, 106, 3, 600),
(12, 6, 2, 103, 4, 2000),
(13, 7, 3, 101, 1, 60000),
(14, 7, 4, 105, 3, 1800),
(15, 8, 5, 102, 2, 45000),
(16, 8, 1, 107, 4, 700);


