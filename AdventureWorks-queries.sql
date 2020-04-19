-- The total sales and the discounts for each product
SELECT p.Name AS ProductName, 
(sod.OrderQty * sod.UnitPrice) AS NonDiscountSales,
((sod.OrderQty * sod.UnitPrice) * sod.UnitPriceDiscount) AS Discounts
FROM Product AS p 
INNER JOIN SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID 
ORDER BY ProductName DESC;

-- The total revenue for each product
SELECT 'Total income is', ((sod.OrderQty * sod.UnitPrice) * (1.0 - sod.UnitPriceDiscount)) AS Revenue, ' for ',
p.Name AS ProductName 
FROM Product AS p 
INNER JOIN SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID 
GROUP BY ProductName
ORDER BY Revenue ASC;

-- Types of Long-Sleeve Logo Jersey
SELECT DISTINCT p.Name
FROM Product AS p 
WHERE EXISTS
    (SELECT *
     FROM ProductModel AS pm 
     WHERE p.ProductModelID = pm.ProductModelID
           AND pm.Name LIKE 'Long-Sleeve Logo Jersey%');
           
-- The average price and the sum of year-to-date sales, grouped by product ID and special offer ID
SELECT sod.ProductID, sod.SpecialOfferID, AVG(sod.UnitPrice) AS AveragePrice, SUM(sod.LineTotal) AS SubTotal
FROM SalesOrderDetail AS sod
GROUP BY ProductID, SpecialOfferID
ORDER BY ProductID

-- Products whose unit price less than 25 and average order quantities are more than 5
SELECT ProductID
FROM SalesOrderDetail
WHERE UnitPrice < 25.00
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID

-- Groups of products that have orders totaling more than $1000000.00 and whose average order quantities are less than 3
SELECT ProductID, AVG(OrderQty) AS AverageQuantity, SUM(LineTotal) AS Total
FROM SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > 1000000.00
AND AVG(OrderQty) < 3

-- Employees who work in 1 and 2 Shifts
SELECT CONCAT(c.firstName,' ',c.lastName) AS Employee, em.Title, edh.StartDate, d.Name AS Department, d.GroupName AS Unit, Shift.ShiftID
FROM contact as c
LEFT JOIN Employee as em ON  c.contactID=em.contactID
LEFT JOIN EmployeeDepartmentHistory as edh ON em.EmployeeID=edh.EmployeeID
LEFT JOIN Department as d ON edh.DepartmentID=d.DepartmentID
LEFT JOIN Shift ON edh.ShiftID=Shift.ShiftID
WHERE Shift.ShiftID IN(1,2)

-- Product transactions by Sales Person 
SELECT soh.SalesPersonID, p.name AS Product, sod.UnitPrice, p.StandardCost, p.ListPrice, sod.OrderQty, SUM(soh.TotalDue) AS TotalSUM
FROM salesorderheader as soh
LEFT JOIN salesorderdetail as sod ON soh.SalesOrderID=sod.SalesOrderID
LEFT JOIN product as p ON p.productID=sod.productID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY p.name
HAVING SUM(soh.TotalDue) IS NOT NULL
ORDER by soh.SalesPersonID

-- Total turnover by each Sales Person 
SELECT soh.SalesPersonID, SUM(soh.TotalDue) AS TotalSUM
FROM salesorderheader AS soh
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY soh.SalesPersonID
HAVING SUM(soh.TotalDue) IS NOT NULL
ORDER by TotalSUM ASC 


-- Subtotals for each bicycle 'Mountain-500%' type by country
SELECT p.name AS Product, SUM(soh.SubTotal) AS TotalSUM, sp.CountryRegionCode AS Country
FROM salesorderheader as soh
LEFT JOIN stateprovince as sp ON soh.TerritoryID=sp.TerritoryID
LEFT JOIN salesorderdetail as sod ON soh.SalesOrderID=sod.SalesOrderID
LEFT JOIN product as p ON p.productID=sod.productID
WHERE p.name LIKE 'Mountain-500%'
GROUP BY p.productID, sp.CountryRegionCode
HAVING SUM(soh.SubTotal) IS NOT NULL
ORDER BY Country, TotalSUM DESC

-- Most popular product for each country 
SELECT p.name AS Product, sp.CountryRegionCode AS Country
FROM salesorderheader as soh
LEFT JOIN stateprovince as sp ON soh.TerritoryID=sp.TerritoryID
LEFT JOIN salesorderdetail as sod ON soh.SalesOrderID=sod.SalesOrderID
LEFT JOIN product as p ON p.productID=sod.productID
GROUP BY sp.CountryRegionCode
HAVING SUM(sod.OrderQty) IS NOT NULL
ORDER BY Country


-- Sales orders with Total Income over $7 000 000 and Quantity per order less than 3, for each Country per Workday/Weekend        
SELECT COUNT(soh.SalesOrderID) as Orders, SUM(soh.SubTotal) AS Income, IF((WEEKDAY(soh.OrderDate))>4, "Weekend", "Workday") AS Weekday, sp.CountryRegionCode AS Country
FROM salesorderheader as soh
LEFT JOIN stateprovince as sp ON soh.TerritoryID=sp.TerritoryID
WHERE EXISTS
    (SELECT *
     FROM salesorderdetail as sod
     WHERE soh.SalesOrderID=sod.SalesOrderID
           AND sod.OrderQty<3)
GROUP BY Weekday, Country
HAVING SUM(soh.SubTotal) > 7000000      
ORDER BY Country

CREATE TEMPORARY TABLE Ivertinimai
SELECT product.Name, product.ListPrice, purchaseorderdetail.UnitPrice, purchaseorderdetail.StockedQty, salesorderdetail.UnitPrice, salesorderdetail.UnitPriceDiscount, salesorderdetail.OrderQty
FROM product
JOIN purchaseorderdetail ON purchaseorderdetail.ProductID=product.ProductID
JOIN salesorderdetail ON salesorderdetail.ProductID=purchaseorderdetail.ProductID

-- Create table 'Evaluations' for Sales Manager with number of orders and sales income change per year for every SalesPerson
CREATE TABLE Evaluations (
    SalesPersonID INTEGER NOT NULL PRIMARY KEY,
    Orders INTEGER,
    SalesIncome VARCHAR(255))

INSERT INTO Evaluations
SELECT sp.SalesPersonID, COUNT(soh.SalesOrderId) AS Orders,
	CASE 
	WHEN SalesLastYear=0 THEN 'New Employee'
	WHEN SalesYTD-SalesLastYear>0 AND SalesLastYear>0 THEN 'Increased Sales'
	ELSE 'Decreased Sales'
	END AS 'SalesIncome'
FROM SalesPerson as sp
LEFT JOIN salesorderheader as soh ON sp.SalesPersonID=soh.SalesPersonID
GROUP BY sp.SalesPersonID

SELECT *
FROM Evaluations

-- Update table 'Evaluations' for SalesPersonID=268 orders from 48 to 148
UPDATE Evaluations
SET Orders=148, SalesIncome='New Employee'
WHERE SalesPersonID=268

-- Delete SalesPersonID=268 from table 'Evaluations' 
DELETE FROM Evaluations
WHERE SalesPersonID=268

-- Delete all info for table 'Evaluations' 
TRUNCATE TABLE Evaluations

-- Delete table
DROP TABLE Evaluations