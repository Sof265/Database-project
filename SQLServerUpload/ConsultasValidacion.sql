USE sales;

-- Validación de búsquedas
-- 1.	¿Cuáles fueron los productos con más y menos ventas?
SELECT TOP 10 p.EnglishProductName, ROUND(SUM(s.SalesAmount),2) AS TotalSales
FROM dbo.products AS p
JOIN dbo.sales AS s
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName
ORDER BY SUM(s.SalesAmount) DESC; -- Top 1: Mountain-200 Black, 46 con 1,373,469.55

SELECT TOP 10 p.EnglishProductName, ROUND(SUM(s.SalesAmount),2) AS TotalSales
FROM dbo.products AS p
JOIN dbo.sales AS s
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName
ORDER BY SUM(s.SalesAmount); -- Top 1: Racing Socks, L con 2427.3

-- 2.	¿Cuál fue el mejor año y mes para las ventas?
SELECT TOP 5 YEAR(s.OrderDate) AS OrderYear, MONTH(s.OrderDate) AS OrderMonth,
ROUND(SUM(s.SalesAmount),2) AS TotalSales
FROM dbo.sales AS s
FULL JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY YEAR(s.OrderDate), MONTH(s.OrderDate)
ORDER BY SUM(s.SalesAmount) DESC; -- Diciembre de 2013, con 1,874,360

-- 3.	¿Qué clientes han aportado más a las ventas? ¿Cuáles son sus características
-- (género, edad, ocupación, nivel de estudios, estado civil, ingresos)?
SELECT TOP 20 c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
DATEDIFF (year, c.BirthDate, GETDATE ()) AS Age,
ROUND(SUM(s.SalesAmount),2) AS TotalSales,
MAX(s.OrderDate) AS LastOrder,
c.Gender, c.EnglishOccupation, c.MaritalStatus, c.EnglishEducation, c.YearlyIncome
FROM dbo.sales AS s
JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName),
c.Gender, c.EnglishOccupation, c.MaritalStatus, c.EnglishEducation, c.YearlyIncome,
DATEDIFF (year, c.BirthDate, GETDATE ())
ORDER BY SUM(s.SalesAmount) DESC;

-- 4. ¿Qué clientes se destacan por el tiempo que llevan comprando, la cantidad y total de compra?
SELECT TOP 10 CustomerName, DATEDIFF(day, DateFirstPurchase, DateLastPurchase)/365.0 AS Years,
PurchaseTotal, ProductsCount, DateLastPurchase
FROM(
SELECT c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
c.DateFirstPurchase, MAX(s.OrderDate) AS DateLastPurchase,
SUM(s.SalesAmount) AS PurchaseTotal, COUNT(CONCAT(s.SalesOrderNumber, s.SalesOrderLineNumber)) AS ProductsCount
FROM dbo.sales AS s
JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName), c.DateFirstPurchase
) AS FirstLastPurchase
WHERE DATEDIFF(month, DateLastPurchase, (SELECT MAX(OrderDate)FROM dbo.sales)) > 6
ORDER BY DATEDIFF(day, DateFirstPurchase, DateLastPurchase)/365.0 DESC,
PurchaseTotal DESC, ProductsCount DESC;

-- Fecha del último pedido
SELECT MAX(OrderDate)
FROM dbo.sales; -- 2014-01-28

-- KPIs

--Crecimiento mensual en las ventas
DECLARE @start_month INT = 10;
DECLARE @start_year INT = 2010;
DECLARE @end_month INT = 2;
DECLARE @end_year INT = 2014;

SELECT YEAR(OrderDate) AS 'Año',
MONTH(OrderDate) AS 'Mes',
SUM(SalesAmount) AS 'Venta del mes',
(SUM(SalesAmount) - LAG(SUM(SalesAmount)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))) / LAG(SUM(SalesAmount)) 
OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) * 100 AS 'Crecimiento'
FROM sales WHERE (YEAR(OrderDate) = @start_year AND MONTH(OrderDate) >= @start_month)
OR(YEAR(OrderDate) > @start_year AND YEAR(OrderDate) < @end_year) 
OR (YEAR(OrderDate) = @end_year AND MONTH(OrderDate) <= @end_month)
GROUP BY YEAR(OrderDate),MONTH(OrderDate)
ORDER BY YEAR(OrderDate),MONTH(OrderDate);

-- Valor de compra promedio por año, por mes
-- Total sales / number of customers
SELECT YEAR(s.OrderDate) AS OrderYear, MONTH(s.OrderDate) AS OrderMonth,
ROUND(SUM(s.SalesAmount)/COUNT(distinct c.CustomerKey),2) AS PurchaseValue
FROM dbo.sales AS s
FULL JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY YEAR(s.OrderDate), MONTH(s.OrderDate)
ORDER BY YEAR(s.OrderDate), MONTH(s.OrderDate);

-- Cálculo de CustomerLifetimeValue
-- (Valor promedio de compra por año) x (número promedio de compras por año para cada cliente)
-- x (vida promedio del cliente en años)
SELECT 
AVG(PurchasePerYear)*
AVG(ProductsPerYear)*
AVG(Years) AS CustomerLifetimeValue 
FROM(
SELECT CustomerName, DateFirstPurchase, DateLastPurchase, 
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN 1 ELSE DATEDIFF(year, DateFirstPurchase, DateLastPurchase) END AS Years,
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN ROUND(PurchaseTotal,2)
ELSE ROUND(PurchaseTotal/NULLIF(DATEDIFF(year, DateFirstPurchase, DateLastPurchase),0),2) END AS PurchasePerYear,
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN ROUND(ProductsCount*1.0,2)
ELSE ROUND(ProductsCount*1.0/NULLIF(DATEDIFF(year, DateFirstPurchase, DateLastPurchase),0),2) END AS ProductsPerYear,
ProductsCount, PurchaseTotal
FROM(
SELECT
c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
c.DateFirstPurchase, 
MAX(s.OrderDate) AS DateLastPurchase,
SUM(s.SalesAmount) AS PurchaseTotal, COUNT(CONCAT(s.SalesOrderNumber, s.SalesOrderLineNumber)) ProductsCount
FROM dbo.sales AS s
JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName), c.DateFirstPurchase
) AS FirstLastPurchase

) AS Purchases;

--Ingreso Promedio por Usuario.
select SUM(s.SalesAmount-s.TaxAmt-s.Freight-s.TotalProductCost)/count(distinct s.CustomerKey) as arpu,
count(distinct s.CustomerKey) as Cliente,
year(OrderDate)
from sales s
group by year(OrderDate)
order by year(OrderDate);

--Margen de beneficio promedio mensual
select round((SUM(SalesAmount-TaxAmt-Freight-TotalProductCost)/SUM((s.salesamount)*(1-p.discountpct)))*100,4) as BeneficioProm,
MONTH(OrderDate) as mes ,year(OrderDate) as year
from sales s join promotion p
on s.PromotionKey = p.PromotionKey
group by MONTH(OrderDate),year(OrderDate)
order by year(OrderDate), MONTH(OrderDate);

--Margen de beneficio promedio puntual
select round((SUM(SalesAmount-TaxAmt-Freight-TotalProductCost)/SUM((s.salesamount)*(1-p.discountpct)))*100,4)
from sales s join promotion p
on s.PromotionKey = p.PromotionKey;

-------------- ANEXOS ------------------

SELECT AVG(SalesAmount) FROM SALES;

-- Potenciales problemas de edad
SELECT MAX(DATEDIFF (year, BirthDate, GETDATE ())) AS Age
FROM customers; --107

-- Promedio de compras y productos adquiridos por cliente en un año.
SELECT CustomerKey, CustomerName, DateFirstPurchase, DateLastPurchase, 
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN 1 ELSE DATEDIFF(year, DateFirstPurchase, DateLastPurchase) END AS Years,
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN ROUND(PurchaseTotal,2)
ELSE ROUND(PurchaseTotal/NULLIF(DATEDIFF(year, DateFirstPurchase, DateLastPurchase),0),2) END AS PurchasePerYear,
CASE WHEN DATEDIFF(year, DateFirstPurchase, DateLastPurchase) = 0
THEN ROUND(ProductsCount*1.0,2)
ELSE ROUND(ProductsCount*1.0/NULLIF(DATEDIFF(year, DateFirstPurchase, DateLastPurchase),0),2) END AS ProductsPerYear,
ProductsCount, PurchaseTotal
FROM(
SELECT
c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
c.DateFirstPurchase, 
MAX(s.OrderDate) AS DateLastPurchase,
SUM(s.SalesAmount) AS PurchaseTotal, COUNT(CONCAT(s.SalesOrderNumber, s.SalesOrderLineNumber)) ProductsCount
FROM dbo.sales AS s
JOIN dbo.customers AS c
ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey, CONCAT(c.FirstName, ' ', c.LastName), c.DateFirstPurchase
) AS FirstLastPurchase
ORDER BY DATEDIFF(year, DateFirstPurchase, DateLastPurchase) DESC;

SELECT *
FROM dbo.promotion;

-- Margen de beneficio promedio
select SUM(s.SalesAmount-s.TaxAmt-s.Freight-s.TotalProductCost)/SUM((s.salesamount)*(1-p.discountpct)),
MONTH(OrderDate),year(OrderDate) as year
from sales s join promotion p
on s.PromotionKey = p.PromotionKey
group by year(OrderDate), MONTH(OrderDate)
order by year(OrderDate), MONTH(OrderDate);

