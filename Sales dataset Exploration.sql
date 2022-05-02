--- Inspecting Data 
SELECT * from portfolioDB.dbo.sales_data_sample

-- Checking unique values
select distinct STATUS 
from portfolioDB.dbo.sales_data_sample

select distinct YEAR_ID 
from portfolioDB.dbo.sales_data_sample

select distinct PRODUCTLINE 
from portfolioDB.dbo.sales_data_sample --- 7 different products

select distinct COUNTRY 
from portfolioDB.dbo.sales_data_sample --- 19 countries 

select distinct DEALSIZE 
from portfolioDB.dbo.sales_data_sample --- Small, medium, large

select distinct TERRITORY 
from portfolioDB.dbo.sales_data_sample

Select distinct MONTH_ID
from portfolioDB.dbo.sales_data_sample
where YEAR_ID = 2005
order by MONTH_ID; --- they only orperated for 5 months 

--- ANALYSIS 
-------Grouping sales by product line 
select PRODUCTLINE,sum(sales) AS Revenue 
FROM portfolioDB.dbo.sales_data_sample
group by PRODUCTLINE
order by 2 desc; 

-------Grouping sales by year 
select YEAR_ID,sum(sales) AS Revenue 
FROM portfolioDB.dbo.sales_data_sample
group by YEAR_ID
order by 2 desc; 

-------Grouping sales by deal size 
select DEALSIZE,sum(sales) AS Revenue 
FROM portfolioDB.dbo.sales_data_sample
group by DEALSIZE
order by 2 desc; 

--- What was the best months for sales per year 

---2003 , best month : June
SELECT MONTH_ID, MAX(sales) as revenue, count(ORDERNUMBER) as Frequency 
FROM portfolioDB.dbo.sales_data_sample
where YEAR_ID=2003
group by MONTH_ID
order by 2 desc; 

---2004 , best month : November 
SELECT MONTH_ID, MAX(sales) as revenue, count(ORDERNUMBER) as Frequency 
FROM portfolioDB.dbo.sales_data_sample
where YEAR_ID=2004
group by MONTH_ID
order by 2 desc; 

--- What products did they sell in november? 
select  PRODUCTLINE,count (ORDERNUMBER) as NumOfOrder,sum(sales) as revenue   
from portfolioDB.dbo.sales_data_sample
where MONTH_ID=11 and YEAR_ID=2004
group by PRODUCTLINE
order by 2 desc; --- The best product are classic cars

---2005 , best month : April
SELECT MONTH_ID, MAX(sales) as revenue, count(ORDERNUMBER) as Frequency 
FROM portfolioDB.dbo.sales_data_sample
where YEAR_ID=2005
group by MONTH_ID
order by 2 desc; 

----Who is our best customer ? (Using Recency-Frequency-Money Value (RFM)  Analysis ) 
drop table if exists #rfm ;
with rfm as 	
(	select 
			CUSTOMERNAME, 
			sum(sales) MonetaryValue,
			avg(sales) AvgMonetaryValue,
			count(ORDERNUMBER) Frequency,
			max(ORDERDATE) last_order_date,
			(select max(ORDERDATE) from portfolioDB.dbo.sales_data_sample) max_order_date,
			DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from portfolioDB.dbo.sales_data_sample)) as Recency
	from [PortfolioDB].[dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as 

(	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm as r 
)
select c.*,rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar) as rfm_cell_string
into #rfm
from rfm_calc as c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm


--- What products are most often sold together? 
select distinct ORDERNUMBER,stuff(
	(select ','+ PRODUCTCODE
	from portfolioDB.dbo.sales_data_sample as first
	where ORDERNUMBER in (
		select ORDERNUMBER
		from (
			select ORDERNUMBER, count(*) as Row_Number
			from portfolioDB.dbo.sales_data_sample
			where STATUS= 'Shipped'
			group by ORDERNUMBER
		) as m 
		where Row_Number= 3
	)
	and first.ORDERNUMBER=second.ORDERNUMBER
	for xml path ('')),1,1,'') as Product_Codes
from portfolioDB.dbo.sales_data_sample as second
order by 2 desc;


--What city has the highest number of sales in a specific country
select city, sum (sales) as Revenue
from PortfolioDB.dbo.sales_data_sample
where country = 'USA'
group by city
order by 2 desc;



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) as Revenue
from PortfolioDB.dbo.sales_data_sample
where country = 'USA'
group by COUNTRY,YEAR_ID, PRODUCTLINE
order by 4 desc;


Tableau Links: 
https://public.tableau.com/app/profile/kimberly6871/viz/SalesDashboard-1_16500729651740/SalesDashboard
https://public.tableau.com/app/profile/kimberly6871/viz/SalesDashboard-2_16500732420150/SalesDashboard2
