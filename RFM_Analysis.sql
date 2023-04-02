--Inspecting Data

select * from [dbo].[sales_data_sample]

--Checking unique values

select distinct STATUS from dbo.sales_data_sample
select distinct YEAR_ID from dbo.sales_data_sample
select distinct PRODUCTLINE from dbo.sales_data_sample
select distinct COUNTRY from dbo.sales_data_sample
select distinct DEALSIZE from dbo.sales_data_sample
select distinct TERRITORY from dbo.sales_data_sample


--ANALYSIS
---Lets start by grouping sales by productline

select PRODUCTLINE,SUM(SALES) Revenue 
from dbo.sales_data_sample
group by PRODUCTLINE
order by 2 desc


select YEAR_ID,SUM(SALES) Revenue 
from dbo.sales_data_sample
group by YEAR_ID
order by 2 desc


select DEALSIZE,SUM(SALES) Revenue 
from dbo.sales_data_sample
group by DEALSIZE
order by 2 desc


--What was the best month for sales in a specific year? How much was earned that month ?

select MONTH_ID,sum(SALES) Revenue,count(ORDERNUMBER) Frequency 
from [dbo].[sales_data_sample]
where YEAR_ID=2004
group by MONTH_ID
order by 2 desc

--November seems to be month,what product do they sell in November,	Classic I believe

select MONTH_ID,PRODUCTLINE,sum(SALES) Revenue,count(ORDERNUMBER) Frequency 
from [dbo].[sales_data_sample]
where YEAR_ID=2004 AND MONTH_ID=11
group by MONTH_ID,PRODUCTLINE
order by 3 desc

--Who is our best customer is (this could be best answered with RFM)


with rfm as (
Select 
       CUSTOMERNAME,
	   sum(sales) MonetaryValue,
	   avg(sales) AvgMonetaryValue,
	   count(ORDERNUMBER) Frequency,
	   max(ORDERDATE) last_order_date,
	   (select max(ORDERDATE) from [dbo].[sales_data_sample]) max_order_date,
	   DATEDIFF(DD,MAX(ORDERDATE),(select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	   from dbo.sales_data_sample
	   GROUP BY CUSTOMERNAME),
rfm_calc as (
select r.*,
       NTILE (4) OVER (order by Recency) rfm_recency,
	   NTILE (4) OVER (order by Frequency) rfm_frequency,
	   NTILE (4) OVER (order by AvgMonetaryValue) rfm_monetary
from rfm r)
select c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
cast(rfm_recency as varchar)+cast(rfm_frequency as varchar)+cast(rfm_monetary as varchar) rfm_cell_string
from rfm_calc c

--What products are most often sold together ?
-- Select * from [dbo].[sales_data_sample] where ORDERNUMBER=10411


select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc
