USE classicmodels;

SELECT * FROM employees;

# Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

#A)
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep' AND reportsTo = 1102;

#B)
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';


#Q2. CASE STATEMENTS for Segmentation

#A)
SELECT customerNumber, customerName,
       CASE
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;



#Q3. Group By with Aggregation functions and Having clause, Date and Time functions

#A)
SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;


#B)
SELECT MONTHNAME(paymentDate) AS Month, COUNT(*) AS PaymentCount
FROM payments
GROUP BY Month
HAVING PaymentCount > 20
ORDER BY PaymentCount DESC;

#Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

#A)

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);


#B)
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (total_amount > 0)
);

#Q5. JOINS
#a. 
SELECT country, COUNT(*) AS OrderCount
FROM customers
JOIN orders ON customers.customerNumber = orders.customerNumber
GROUP BY country
ORDER BY OrderCount DESC
LIMIT 5;


#Q6. Self Join
#a) 

CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);
INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Alice', 'Female', NULL),
('Bob', 'Male', 1),
('Charlie', 'Male', 2),
('David', 'Male', 2),
('Eva', 'Female', 1);

SELECT e1.FullName AS Employee, e2.FullName AS Manager
FROM project e1
JOIN project e2 ON e1.ManagerID = e2.EmployeeID;


#Q7. DDL Commands: Create, Alter, Rename
#a) 
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD city VARCHAR(50) NOT NULL AFTER Name;

desc facility;


#Q8. Views in SQL
#a) Create a view named product_category_sales.

CREATE VIEW product_category_sales AS
SELECT p.productLine AS ProductCategory,
       SUM(od.quantityOrdered * od.priceEach) AS TotalSales,
       COUNT(DISTINCT o.orderNumber) AS NumberOfOrders
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productLine;

select * from product_category_sales;


#Q9. Stored Procedures in SQL with Parameters
#a) 

DELIMITER //
CREATE PROCEDURE Get_country_payments(IN year INT, IN country VARCHAR(50))
BEGIN
    SELECT year(paymentDate) AS Year, country,
           FORMAT(SUM(amount), 'K') AS TotalAmount
    FROM payments
    JOIN customers ON payments.customerNumber = customers.customerNumber
    WHERE year(paymentDate) = year AND country = country
    GROUP BY Year, country;
END //
DELIMITER ;


#Q10. Window functions - Rank, dense_rank, lead and lag
#a) 
SELECT 
    c.customerNumber, 
    c.customerName,
    COUNT(o.orderNumber) AS OrderCount,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS OrderRank
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY OrderCount DESC;

#b) 
SELECT year(orderDate) AS Year, MONTHNAME(orderDate) AS Month,
       COUNT(orderNumber) AS OrderCount,
       ROUND((COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (ORDER BY year(orderDate))) 
             / LAG(COUNT(orderNumber)) OVER (ORDER BY year(orderDate)) * 100, 0) AS YoYChange
FROM orders
GROUP BY Year, Month;


#Q11.Subqueries and their applications
#A. 

SELECT productLine, COUNT(*) AS ProductCount
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;

#Q12. ERROR HANDLING in SQL 

DELIMITER //
CREATE PROCEDURE Insert_Emp (IN EmpID INT, IN EmpName VARCHAR(50), IN EmailAddress VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred';
    END;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (EmpID, EmpName, EmailAddress);
END //
DELIMITER ;




#Q13 TRIGGERS

    CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours int
);

select * from emp_bit;

INSERT INTO Emp_BIT (Name, Occupation, Working_date,working_hours)
VALUES ('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);


DELIMITER //
CREATE TRIGGER positive_working_hours
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //
DELIMITER ;






