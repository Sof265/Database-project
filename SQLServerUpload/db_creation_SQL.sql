-- /================DB NAME==================/
CREATE DATABASE sales;
-- /================DB NAME==================/
USE sales;
-- /================CREACION DE TABLAS==================/
CREATE TABLE products(
  ProductKey int primary key NOT NULL,
  ProductAlternateKey varchar(10),
  ProductSubcategoryKey float,
  EnglishProductName varchar(40) NOT NULL,
  StandardCost float(15),
  FinishedGoodsFlag varchar(5) NOT NULL,
  Color varchar(20),
  SafetyStockLevel int,
  ReorderPoint int,
  ListPrice float,
  Weight float,
  DaysToManufacture int,
  ProductLine varchar(4),
  DealerPrice float,
  Class varchar(4),
  Style varchar(4),
  ModelName varchar(50),
  EnglishDescription varchar(400),
  StartDate date,
  EndDate date,
  Status varchar(8),
  SizeClothes varchar(2),
  SizeParts varchar(10)
);
CREATE TABLE customers(
	CustomerKey int not null primary key,
	FirstName varchar(11),
	MiddleName varchar(10),
	LastName varchar(16),
	BirthDate date,
	MaritalStatus varchar(1),
	Gender varchar(1),
	EmailAddress varchar(33),
	YearlyIncome int,
	TotalChildren int,
	NumberChildrenAtHome int,
	EnglishEducation varchar(20),
	EnglishOccupation varchar(15),
	HouseOwnerFlag int,
	NumberCarsOwned int,
	AddressLine1 varchar(40),
	Phone varchar(20),
	DateFirstPurchase date,
	CommuteDistanceMin float,
	CommuteDistanceMax float);

CREATE TABLE currency(
	CurrencyKey int primary key,
	CurrencyAlternateKey varchar(3),
	CurrencyName varchar(30));

CREATE TABLE promotion(
	PromotionKey int primary key,
	EnglishPromotionName varchar(40),
	DiscountPct float,
	EnglishPromotionType varchar(20),
	EnglishPromotionCategory varchar(15),
	StartDate date,
	EndDate date,
	MixQty int,
	MaxQty int);


CREATE TABLE sales(
	ProductKey int NOT NULL,
	CustomerKey int NOT NULL,
	PromotionKey int NOT NULL,
	CurrencyKey int NOT NULL,
	SalesOrderNumber varchar(7),
	SalesOrderLineNumber int NOT NULL,
	UnitPrice float,
	ExtendedAmount float,
	ProductStandardCost float,
	TotalProductCost float,
	SalesAmount float,
	TaxAmt float,
	Freight float,
	OrderDate date,
	DueDate date,
	ShipDate date,
	FOREIGN KEY (ProductKey) REFERENCES products(ProductKey),
	FOREIGN KEY (PromotionKey) REFERENCES promotion(PromotionKey),
	FOREIGN KEY (CurrencyKey) REFERENCES currency(CurrencyKey),
	FOREIGN KEY (CustomerKey) REFERENCES customers(CustomerKey),
	PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber));

-- /================CREACION DE TABLAS==================/

-- /================BULK INSERT CSV A SQL POR TABLA==================/

BULK INSERT dbo.promotion
FROM 'C:\Users\sbriceno\OneDrive - Capgemini\Documents\SQL\Proyecto\DatosLimpios\PROMOTION_clean.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2,
		ROWTERMINATOR = '0x0a'
)
GO


BULK INSERT dbo.currency
FROM 'C:\Users\sbriceno\OneDrive - Capgemini\Documents\SQL\Proyecto\DatosLimpios\CURRENCY.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2,
		ROWTERMINATOR = '0x0a'
)
GO


BULK INSERT dbo.sales
FROM 'C:\Users\sbriceno\OneDrive - Capgemini\Documents\SQL\Proyecto\DatosLimpios\SALES_clean.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2,
		ROWTERMINATOR = '0x0a'
)
GO

BULK INSERT dbo.customers
FROM 'C:\Users\sbriceno\OneDrive - Capgemini\Documents\SQL\Proyecto\DatosLimpios\CUSTOMERS_clean.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2,
		ROWTERMINATOR = '0x0a'
)
GO

BULK INSERT dbo.products
FROM 'C:\Users\sbriceno\OneDrive - Capgemini\Documents\SQL\Proyecto\DatosLimpios\PRODUCTS_clean.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2,
		ROWTERMINATOR = '0x0a'
)
GO

-- /================BULK INSERT CSV A SQL POR TABLA==================/