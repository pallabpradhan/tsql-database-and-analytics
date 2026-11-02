USE ShopDB;
GO

-- 1. Monthly revenue (excluding cancelled orders)
SELECT FORMAT(o.OrderDate, 'yyyy-MM') AS [Month],
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM Orders o
JOIN OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status <> 'Cancelled'
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY [Month];

-- 2. Month-over-month growth using LAG()
WITH Monthly AS (
    SELECT FORMAT(o.OrderDate, 'yyyy-MM') AS [Month],
           SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM Orders o
    JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status <> 'Cancelled'
    GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
)
SELECT [Month], Revenue,
       LAG(Revenue) OVER (ORDER BY [Month]) AS PrevMonth,
       CAST(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY [Month]))
            / NULLIF(LAG(Revenue) OVER (ORDER BY [Month]), 0) AS DECIMAL(6,2)) AS GrowthPct
FROM Monthly;

-- 3. Top customers by spend with RANK()
SELECT c.FullName, c.City,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent,
       RANK() OVER (ORDER BY SUM(oi.Quantity * oi.UnitPrice) DESC) AS SpendRank
FROM Customers c
JOIN Orders o       ON o.CustomerID = c.CustomerID AND o.Status <> 'Cancelled'
JOIN OrderItems oi  ON oi.OrderID = o.OrderID
GROUP BY c.FullName, c.City;

-- 4. Best-selling product in each category (ROW_NUMBER + CTE)
WITH ProductSales AS (
    SELECT p.Category, p.ProductName,
           SUM(oi.Quantity) AS UnitsSold,
           ROW_NUMBER() OVER (PARTITION BY p.Category
                              ORDER BY SUM(oi.Quantity) DESC) AS rn
    FROM Products p
    JOIN OrderItems oi ON oi.ProductID = p.ProductID
    JOIN Orders o      ON o.OrderID = oi.OrderID AND o.Status <> 'Cancelled'
    GROUP BY p.Category, p.ProductName
)
SELECT Category, ProductName, UnitsSold FROM ProductSales WHERE rn = 1;

-- 5. Products that have never been sold
SELECT p.ProductID, p.ProductName
FROM Products p
LEFT JOIN OrderItems oi ON oi.ProductID = p.ProductID
WHERE oi.OrderItemID IS NULL;

-- 6. Customer segmentation with CASE
SELECT c.FullName,
       COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSpent,
       CASE
           WHEN COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) >= 5000 THEN 'Gold'
           WHEN COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) >= 2000 THEN 'Silver'
           ELSE 'Bronze'
       END AS Segment
FROM Customers c
LEFT JOIN Orders o      ON o.CustomerID = c.CustomerID AND o.Status <> 'Cancelled'
LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY c.FullName
ORDER BY TotalSpent DESC;

-- 7. Running total of revenue by order date
SELECT o.OrderDate,
       SUM(oi.Quantity * oi.UnitPrice) AS DayRevenue,
       SUM(SUM(oi.Quantity * oi.UnitPrice)) OVER (ORDER BY o.OrderDate) AS RunningTotal
FROM Orders o
JOIN OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status <> 'Cancelled'
GROUP BY o.OrderDate
ORDER BY o.OrderDate;

-- 8. Repeat customers (more than one order)
SELECT c.FullName, COUNT(o.OrderID) AS Orders
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
WHERE o.Status <> 'Cancelled'
GROUP BY c.FullName
HAVING COUNT(o.OrderID) > 1;
