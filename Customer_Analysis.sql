
SELECT *
FROM dbo.marketing_campaign;

---Finding the number of customers
SELECT COUNT(DISTINCT ID)
FROM DBO.marketing_campaign;

---Looking for missing values
SELECT *
FROM dbo.marketing_campaign
WHERE Year_Birth IS NULL;

SELECT *
FROM dbo.marketing_campaign
WHERE Education IS NULL;

SELECT *
FROM dbo.marketing_campaign
WHERE Marital_Status IS NULL;

SELECT *
FROM dbo.marketing_campaign
WHERE Income IS NULL;

SELECT *
FROM dbo.marketing_campaign
WHERE Kidhome IS NULL;

--Creating a column named "NumKids"
ALTER TABLE dbo.marketing_campaign
ADD NumKids INT;

UPDATE dbo.marketing_campaign
SET NumKids=Kidhome+Teenhome;

--Creating a column named "Age"
ALTER TABLE dbo.marketing_campaign
ADD Age INT;

UPDATE dbo.marketing_campaign
SET Age= 2021-Year_Birth;

--Creating a column named "CustomerFor"
ALTER TABLE dbo.marketing_campaign
ADD CustomerFor INT;

UPDATE dbo.marketing_campaign
SET CustomerFor=DATEDIFF(year,dt_customer,'2021-11-19');

--Changing responses in coulumn "Complain" to "Yes" or "No"
SELECT
	ID,
	Complain,
	CASE WHEN Complain=1 THEN 'Yes'
	ELSE 'No'
	END
FROM dbo.marketing_campaign;

ALTER TABLE dbo.marketing_campaign
ADD Complaints VARCHAR(5);

UPDATE dbo.marketing_campaign
SET Complaints= CASE WHEN Complain=1 THEN 'Yes' ELSE 'No' END;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Complain;

--Removing columns we won't use in the analysis
SELECT *
FROM dbo.marketing_campaign;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Recency;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Kidhome;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN TeenHome;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN AcceptedCmp1;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN AcceptedCmp2;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN AcceptedCmp3;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN AcceptedCmp4;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN AcceptedCmp5;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Z_CostContact;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Z_Revenue;

ALTER TABLE dbo.marketing_campaign
DROP COLUMN Response;

---------------------------------------------------------------------------------------------------
--ANALYSIS

--Find the customers level of education
SELECT
	Education,
	COUNT(Education)
FROM dbo.marketing_campaign
GROUP BY Education
ORDER BY COUNT(Education) DESC;

--Find the customers marital status
SELECT
	Marital_Status,
	COUNT(Marital_status) 
FROM dbo.marketing_campaign
GROUP BY Marital_Status
ORDER BY COUNT(Marital_status) DESC;

--Classifying the age groups by generations
SELECT MIN(Age)
FROM dbo.marketing_campaign;

SELECT MAX(Age)
FROM dbo.marketing_campaign;

SELECT TOP 10 Age
FROM dbo.marketing_campaign
ORDER BY Age DESC;


ALTER TABLE dbo.marketing_campaign
ADD Generation VARCHAR(50);

UPDATE dbo.marketing_campaign
SET Generation =
	(CASE WHEN Age BETWEEN 25 AND 40 THEN 'Millennial'
	WHEN Age BETWEEN 41 AND 56 THEN 'Gen X'
	WHEN Age BETWEEN 57 AND 66 THEN 'Boomers II'
	WHEN Age BETWEEN 67 AND 75 THEN 'Boomers I'
	WHEN Age BETWEEN 76 AND 93 THEN 'Post War'
	WHEN Age BETWEEN 94 AND 99 THEN 'WW2'
	ELSE 'Verify the birth year' 
	END);

SELECT 
	Generation,
	COUNT(Generation)
FROM dbo.marketing_campaign
GROUP BY Generation
ORDER BY 2;

--Is there a correlation between the income and the number of kids?
SELECT 
	SUM(Income),
	NumKids
FROM dbo.marketing_campaign
WHERE Income IS NOT NULL
GROUP BY NumKids
ORDER BY NumKids;

--Is there a correlation between the income and the level of education?
SELECT 
	Income,
	Education
FROM dbo.marketing_campaign;

--Do people with kids spend more money on sweets?
SELECT
	SUM(MntSweetProducts),
	NumKids
FROM dbo.marketing_campaign
GROUP BY NumKids
ORDER BY Numkids;

--The percent of customers that have kids
ALTER TABLE dbo.marketing_campaign
ADD HasKids VARCHAR(5);

UPDATE dbo.marketing_campaign
SET HasKids=
	( CASE WHEN NumKids IN (1,2,3) THEN 'Yes'
		ELSE 'No'
		END);

SELECT 
	HasKids,
	COUNT(HasKids)
FROM dbo.marketing_campaign
GROUP BY HasKids;

--On what products do customers spend the most?
SELECT
	SUM(MntFishProducts) AS TotalSpentOnFish,
	SUM(MntFruits) AS TotalSpentOnFruits,
	SUM(MntGoldProds) AS TotalSpentOnGold,
	SUM(MntMeatProducts) AS TotalSpentOnMeat,
	SUM(MntSweetProducts) AS TotalSpentOnSweet,
	SUM(MntWines) AS TotalSpentOnWine
FROM dbo.marketing_campaign;


---The average income
SELECT AVG(Income)
FROM dbo.marketing_campaign;

---The average years of being a customer
SELECT AVG(CustomerFor)
FROM dbo.marketing_campaign;

--Who is spending the most?
SELECT 
	Generation,
	SUM(MntWines+MntFruits+MntMeatProducts+MntFishProducts+MntSweetProducts+MntGoldProds) AS TotalSpend
FROM dbo.marketing_campaign
GROUP BY Generation;

SELECT 
	Education,
	SUM(MntWines+MntFruits+MntMeatProducts+MntFishProducts+MntSweetProducts+MntGoldProds) AS TotalSpend
FROM dbo.marketing_campaign
GROUP BY Education;

--Is there a lot of complaints?
SELECT
	Complaints,
	COUNT(Complaints)
FROM dbo.marketing_campaign
GROUP BY Complaints;

--Web purchases vs Store purchases
SELECT
	SUM(NumWebPurchases) AS PurchasedOnWeb,
	SUM(NumStorePurchases) AS PurchasedInStore
FROM dbo.marketing_campaign;

--Do people with kids spend the most?
SELECT
	HasKids,
	SUM(Income)
FROM dbo.marketing_campaign
GROUP BY HasKids
ORDER BY SUM(Income) DESC;