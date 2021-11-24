--Data exploration
--First dataset: Daily activity

SELECT *
FROM dbo.dailyActivity_merged;

SELECT *
FROM dbo.dailyActivity_merged
WHERE TotalSteps=0;

--Find the number of users
SELECT DISTINCT Id
FROM dbo.dailyActivity_merged;

--Second dataset: Daily Calories
SELECT *
FROM dbo.dailyCalories_merged;

--Find the number of users
SELECT DISTINCT Id
FROM dbo.dailyCalories_merged;

--Detecting missing info
SELECT *
FROM dbo.dailyCalories_merged
WHERE Calories=0;
 
 SELECT *
 FROM dbo.dailyCalories_merged
 WHERE Calories IS NULL;

 --Third Dataset: Daily Intensities
 SELECT *
 FROM dbo.dailyIntensities_merged;


 --Finding the number of users
 SELECT DISTINCT Id
 FROM dbo.dailyIntensities_merged;

 --Finding Missing information
 SELECT *
 FROM dbo.dailyIntensities_merged
 WHERE SedentaryMinutes=0;

 SELECT *
 FROM dbo.dailyIntensities_merged
 WHERE SedentaryMinutes IS NULL;

 --FOURTH DATASET: DAILY STEPS
 SELECT *
 FROM dbo.dailySteps_merged;

 SELECT COUNT (DISTINCT Id)
 FROM dbo.dailySteps_merged;

--Missing info
SELECT *
FROM dbo.dailySteps_merged
WHERE StepTotal=0;

---FIFTH DATASET: SLEEP DAY
SELECT *
FROM dbo.sleepDay_merged;

SELECT COUNT(DISTINCT Id)
FROM dbo.sleepDay_merged;

--Missing info
SELECT *
FROM dbo.sleepDay_merged
WHERE TotalSleepRecords=0 OR TotalMinutesAsleep=0 OR TotalTimeInBed=0;

--Changing Sleep Day type (from datetime to date)
SELECT SleepDay,
CAST(SleepDay AS DATE)
FROM dbo.sleepDay_merged;

ALTER TABLE sleepDay_merged
ADD SleepDayConverted DATE;

UPDATE sleepDay_merged
SET SleepDayConverted=CONVERT(DATE,SleepDay);

ALTER TABLE sleepDay_merged
DROP COLUMN SleepDay;

--SIXTH DATASET: WEIGHT LOG INFO
SELECT *
FROM dbo.weightLogInfo_merged;

SELECT COUNT(DISTINCT Id)
FROM dbo.weightLogInfo_merged;

SELECT *
FROM dbo.weightLogInfo_merged
WHERE Fat IS NULL;

SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = 'weightLogInfo_merged' AND 
     COLUMN_NAME = 'Date';

SELECT 
	Date,
	CONVERT(date,date) AS Date,
	CONVERT(TIME,Date) AS Time
FROM weightLogInfo_merged;

ALTER TABLE weightLogInfo_merged
ADD 
	LogDate DATE,
	LogTime TIME;

UPDATE weightLogInfo_merged
SET LogDate = CONVERT(DATE,Date);

UPDATE weightLogInfo_merged
SET LogTime=CONVERT(TIME,Date)

---Joining the datasets 

CREATE TABLE MergedDataset
(	Id BIGINT,
	ActivityDate DATE,
	TotalSteps BIGINT,
	Calories INT,
	SedentaryMinutes INT,
	MinutesAsleep BIGINT,
	WeightInPounds FLOAT,
	TotalActiveMinutes INT) 


INSERT INTO MergedDataset 
SELECT 
	DA.Id,
	DA.ActivityDate,
	DA.TotalSteps,
	DA.Calories,
	DI.SedentaryMinutes,
	SD.TotalMinutesAsleep,
	WI.WeightPounds,
	DA.FairlyActiveMinutes+DA.LightlyActiveMinutes+DA.VeryActiveMinutes
FROM dailyActivity_merged AS DA
LEFT JOIN dailyCalories_merged AS DC
	ON DA.Id=DC.Id AND DA.Calories=DC.Calories AND DA.ActivityDate=DC.ActivityDay
LEFT JOIN dailyIntensities_merged AS DI
	ON DA.Id=DI.Id AND DA.ActivityDate=DI.ActivityDay AND DA.SedentaryMinutes=DI.SedentaryMinutes AND DA.VeryActiveMinutes=DI.VeryActiveMinutes
LEFT JOIN dailySteps_merged AS DS
	ON DA.Id=DS.Id AND DA.ActivityDate=DS.ActivityDay AND DA.TotalSteps=DS.StepTotal
LEFT JOIN sleepDay_merged AS SD
	ON DA.Id=SD.Id AND DA.ActivityDate=SD.SleepDayConverted
LEFT JOIN weightLogInfo_merged AS WI
	ON DA.Id=WI.Id AND DA.ActivityDate=WI.LogDate;

SELECT *
FROM MergedDataset;

SELECT COUNT(DISTINCT Id) 
FROM MergedDataset;


--Finding the average Steps taken overall
SELECT 
	AVG(TotalSteps)
FROM MergedDataset;

--Finding the average Steps taken by each users during the month
SELECT 
	Id,
	AVG(TotalSteps)
FROM MergedDataset
GROUP BY Id
ORDER BY 2;

--Finding the average Steps taken for each day
SELECT
	ActivityDate,
	AVG(Totalsteps)
FROM MergedDataset
GROUP BY ActivityDate
ORDER BY ActivityDate;

--Finding the average calories burned
SELECT AVG(Calories)
FROM MergedDataset;

---------------------------------------------------------------------------------------------------------------------------
--WHEN ARE PEOPLE WALKING THE MOST?
SELECT *
FROM hourlySteps_merged;

ALTER TABLE hourlySteps_merged
ADD ActivityDay DATE,
	ActivityTime TIME;
-----Categorizing the part of the day(morning,afternoon,nightime)
UPDATE hourlySteps_merged
SET ActivityDay=CONVERT(date,ActivityHour);

UPDATE hourlySteps_merged
SET ActivityTime=CONVERT(TIME,ActivityHour);

ALTER TABLE hourlySteps_merged
DROP COLUMN PartOfDay;

ALTER TABLE hourlySteps_merged
ADD PartOfDay NVARCHAR(15);

UPDATE hourlySteps_merged
SET PartOfDay =
	(CASE WHEN DATEPART(HH,ActivityHour) BETWEEN 0 AND 12 THEN 'Morning'
		 WHEN DATEPART(HH,ActivityHour) BETWEEN 13 AND 18 THEN 'Afternoon'
		 WHEN DATEPART(HH,ActivityHour) BETWEEN 19 AND 24 THEN 'Nightime'
	END) ;

SELECT 
	SUM(StepTotal),
	PartOfDay
FROM hourlySteps_merged 
GROUP BY PartOfDay
ORDER BY SUM(StepTotal) DESC;

---------------------------------------------------------------------------------------------------------------------
SELECT *
FROM MergedDataset;

--When were people the most active?
SELECT 
	ActivityDate,
	SUM(TotalSteps) AS TotalSteps
FROM MergedDataset
GROUP BY ActivityDate
ORDER BY SUM(TotalSteps) DESC;



--When did people burn the most calories?
SELECT 
	ActivityDate,
	SUM(Calories)
FROM MergedDataset
GROUP BY ActivityDate
ORDER BY SUM(Calories) DESC;

--Is there a correlation between the Total Of Steps taken and the Total of calories burned
--Hypothesis : the more steps you take the more calories you burn : FALSE
SELECT 
	ID,
	SUM(Calories) AS Caloriesburnt,
	SUM(TotalSteps) AS StepsTaken
FROM MergedDataset
GROUP BY Id
ORDER BY SUM(TotalSteps);

--The average sedentary minutes in hours (16 hours )
SELECT 
	AVG(SedentaryMinutes),
	AVG(SedentaryMinutes)/60
FROM MergedDataset;

--The average of active minutes in hours (3 hours)

SELECT 
	AVG(TotalActiveMinutes)/60
FROM MergedDataset;

--Is there a correlation between the number of active minutes and the calories bunrned
SELECT
	ID,
	SUM(calories) AS CaloriesBurned,
	SUM(TotalactiveMinutes) AS ActiveMinutes
FROM MergedDataset
GROUP BY Id
ORDER BY SUM(TotalActiveMinutes);

-------------------------------------------------------------------------------------------------------------------
--Queries for Tableau viz

SELECT
	ActivityDate,
	TotalSteps
FROM MergedDataset;

--Is there a correlation between the Total Of Steps taken and the Total of calories burned
--Hypothesis : the more steps you take the more calories you burn : FALSE
SELECT 
	ID,
	SUM(Calories) AS Caloriesburnt,
	SUM(TotalSteps) AS StepsTaken
FROM MergedDataset
GROUP BY Id;