use mintclassics;
#Total Revenue    
SELECT SUM(quantityOrdered * priceEach) AS TotalRevenue
FROM orderdetails;
 
#Average Order Value
SELECT AVG(quantityOrdered * priceEach) AS AvgOrderValue
FROM orderdetails;

#Inventory Turnover Ratio - How quickly inventory is sold and replaced within a given period.
SELECT (SUM(quantityOrdered) / AVG(quantityInStock)) AS InventoryTurnoverRatio
FROM orderdetails
JOIN products ON orderdetails.productCode = products.productCode;

#Days Inventory Outstanding - DIO - Average number of days it takes to sell inventory.
SELECT (AVG(quantityInStock) / (SUM(quantityOrdered) / 365)) AS DIO
FROM orderdetails
JOIN products ON orderdetails.productCode = products.productCode;

#Customer Lifetime Value - Predicted value a customer will contribute to the business over their entire relationship.
SELECT AVG(od.priceEach * od.quantityOrdered) AS AvgOrderAmount, COUNT(DISTINCT o.orderNumber) AS OrderCount, AVG(c.creditLimit) AS AvgCreditLimit
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber;

#-Order Fulfillment Rate - Percentage of customer orders successfully fulfilled within a target timeframe.
SELECT (COUNT(CASE WHEN status = 'Shipped' THEN orderNumber END) / COUNT(orderNumber)) * 100 AS OrderFulfillmentRate
FROM orders;

#Number of customers handled by each employee
SELECT cus.salesRepEmployeeNumber AS 'Emp Number',
concat(emp.firstName, " ", emp.lastName) AS 'FullName', jobTitle, reportsTo,
count(cus.customerNumber) AS 'Number of Customers'
FROM employees emp RIGHT JOIN customers cus
ON emp.employeeNumber = cus.salesRepEmployeeNumber
GROUP BY salesRepEmployeeNumber 
ORDER BY count(cus.customerNumber) DESC;

#Employee Productivity (Sales per Employee)
SELECT customers.salesRepEmployeeNumber, concat(employees.firstName, " ", employees.lastName) AS 'Full_Name', ROUND(SUM(quantityOrdered * priceEach) / COUNT(DISTINCT salesRepEmployeeNumber), 2) AS SalesPerEmployee
FROM orderdetails
JOIN orders ON orders.orderNumber = orderdetails.orderNumber
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON Customers.salesRepEmployeeNumber = employees.employeeNumber
GROUP BY customers.salesRepEmployeeNumber;

#Checking for the total ordered quantity and the number of orders for each product. 
SELECT p.productCode, p.productName, p.quantityInStock AS 'Current Total Quantity in Stock',
    SUM(od.quantityOrdered) AS 'Total Ordered Quantity',
    COUNT(od.orderNumber) AS 'Total Orders'
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.quantityInStock;

#Show the list of orders via Status.
select status, count(orderNumber)
from orders
group by status;

#Order status numbers across warehouses
SELECT 
    w.warehouseName,
    SUM(CASE WHEN o.status = 'Shipped' THEN 1 ELSE 0 END) AS `Shipped Counts`,
    SUM(CASE WHEN o.status = 'Resolved' THEN 1 ELSE 0 END) AS `Resolved Counts`,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS `Cancelled Counts`,
    SUM(CASE WHEN o.status = 'On Hold' THEN 1 ELSE 0 END) AS `On Hold Counts`,
    SUM(CASE WHEN o.status = 'Disputed' THEN 1 ELSE 0 END) AS `Dispute Counts`,
    SUM(CASE WHEN o.status = 'In Process' THEN 1 ELSE 0 END) AS `In Process Counts`
FROM 
    orders o
JOIN 
    orderdetails od ON o.orderNumber = od.orderNumber
JOIN 
    products p ON od.productCode = p.productCode
JOIN 
    warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY 
    w.warehouseName;

#number of instock across various warehouses.
select w.warehouseName, w.warehouseCode, sum(quantityInStock) as 'Total Items in Stock'
from warehouses w
join products p 
on w.warehouseCode = p.warehouseCode
group by w.warehouseCode;

select count(distinct(orderNumber)) from orderdetails;

#Total Items in stock and Total Items ordered across all the warehouses.
select 
	w.warehouseName, 
	w.warehouseCode, 
	count(distinct(ord.orderNumber)) as 'Number of orders',
	sum(quantityInStock) as 'Total Items in Stock', 
	sum(quantityOrdered) as 'Total Items (Qty) ordered',
	(sum(p.quantityInStock) + sum(ord.quantityOrdered)) as 'Total Items'
from warehouses w
left join products p 
on w.warehouseCode = p.warehouseCode
left join orderdetails ord 
on p.productCode =  ord.productCode
group by w.warehouseCode;

#To check if there is zero stock and ordered items
select 
    w.warehouseName, 
    w.warehouseCode, 
    sum(p.quantityInStock) as 'Total Items in Stock', 
    sum(ord.quantityOrdered) as 'Total Items (Qty) Ordered',
    (sum(p.quantityInStock) + SUM(ord.quantityOrdered)) as 'Total Items'
from warehouses w
left join products p 
on w.warehouseCode = p.warehouseCode
Left join orderdetails ord 
on p.productCode = ord.productCode
group by w.warehouseName, w.warehouseCode
having (sum(p.quantityInStock) + sum(ord.quantityOrdered)) = 0;


select count(distinct(productName)) from products;

# sales percentage of various products 
select 
p.productName,
 avg(ord.priceEach * ord.quantityOrdered)  as 'Averge Sale Price',
 (sum(ord.priceEach * ord.quantityOrdered) / (select sum(priceEach * quantityOrdered) from orderdetails ))*100 as 'Sales percentage'
from 
products p 
join orderdetails ord
on p.productCode = ord.productCode
group by p.productName
order by 'Total Price' desc;

#the profit percentage of each product
select 
p.productName,
avg(p.buyPrice) as 'Avg Cost Price',
avg(ord.priceEach) as 'Average Selling Price',
sum(ord.priceEach * ord.quantityOrdered) as 'Total Revenue',
sum(p.buyPrice * ord.quantityOrdered) as 'Total Cost',
(sum(ord.priceEach * ord.quantityOrdered) - sum(p.buyPrice * ord.quantityOrdered)) as totalProfit,
((sum(ord.priceEach * ord.quantityOrdered) - sum(p.buyPrice * ord.quantityOrdered)) / sum(p.buyPrice * ord.quantityOrdered)) * 100 as 'profitPercentage'
from 
products p 
join orderdetails ord
on p.productCode = ord.productCode
group by p.productName
order by `profitPercentage` desc;


