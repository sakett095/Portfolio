													-- ADVENTURE WORKS
# About Company
-- Adventure Works Cycles, the company on which the Adventure Works sample databases are based, is a large, multinational manufacturing company. 
-- The company manufactures and sells metal and composite bicycles to North American, European and Asian commercial markets. While its base 
-- operation is in Bothell, Washington with 290 employees, several regional sales teams are located throughout their market base.
-- In 2000s, Adventure Works Cycles bought a small manufacturing plant in Mexico. Which manufactures several critical subcomponents for 
-- the Adventure Works Cycles product line. These subcomponents are shipped to the Bothell location for final product assembly. In 2001, this 
-- manufacturing plant became the sole manufacturer and distributor of the touring bicycle product group.

#  Problem Statement
-- Coming off a successful fiscal year, Adventure Works Cycles is looking to broaden its market share by targeting their sales to their best 
-- customers, extending their product availability through an external Web site, and reducing their cost of sales through lower production costs.


# As per the problem statement I write multiple SQL queries to fetch the insights from the datasets.

#========================================================================================================================================================


#1.Lookup the productname from the Product sheet to Sales sheet.
select Order_Date,EnglishProductName from adventureworks.salesmerged as s inner join adventureworks.dimproduct p on s.ProductKey=p.ProductKey;

#2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.
select order_date,case when middlename is null then concat(firstname,' ',lastname) else
concat(firstname,' ',middlename,' ',lastname) end as FullName, `Unit Price`
from adventureworks.salesmerged s inner join adventureworks.dimcustomer c on s.CustomerKey=c.CustomerKey
inner join adventureworks.dimproduct p on s.ProductKey=p.ProductKey;

#3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
--    A.Year
select *, year(order__date) as year from adventureworks.salesmerged;

--    B.Monthno
select *, month(order__date) as Month from adventureworks.salesmerged order by month;

--    C.Monthfullname
select *, monthname(order__date) as Month_Name from adventureworks.salesmerged;

--    D.Quarter(Q1,Q2,Q3,Q4)
select *, concat("Q",quarter(order__date)) as Quarter from adventureworks.salesmerged;

--    E. YearMonth ( YYYY-MMM)
select *,date_format(order__date,"%Y-%m") as YYYY_MMM from adventureworks.salesmerged;
select *,concat(year(order__date),"-",left(monthname(order__date),3)) as `Year-Month` from adventureworks.salesmerged;
select *,concat(year(order__date),"-",left(monthname(order__date),3)) as "Year-Month" from adventureworks.salesmerged;

--    F. Weekdayno
select *,weekday(order__date) Weekday from adventureworks.salesmerged order by Weekday ;

--    G.Weekdayname
select *,dayname(order__date) WeekdayName from adventureworks.salesmerged ;

--    H.FinancialMOnth
select *,if(month(order__date)>3,concat("FM",month(order__date)-3),concat("FM",month(order__date)+9)) as Financialmonth
from adventureworks.salesmerged;

--    I. Financial Quarter 
select *,if(quarter(order__date)>1,concat("Q",quarter(order__date)-1),concat("Q",4)) as FinancialQuarter
from adventureworks.salesmerged;

#4.Calculate the Sales amount using the columns(unit price,order quantity,unit discount)
select *,round(UnitPrice*OrderQuantity-DiscountAmount,2) as Sales_Amount_ from adventureworks.salesmerged;

#5.Calculate the Productioncost uning the columns(unit cost ,order quantity)
select *,round(ProductStandardCost*OrderQuantity,2) as Production_Cost from adventureworks.salesmerged;

#6.Calculate the profit.
select *,round(Sales_Amount-Production_Cost-Freight-TaxAmt,2) as Profit from adventureworks.salesmerged;

#7.Create a Pivot table for month and sales (provide the Year as filter to select a particular Year)
select year(order__date) as Year,month(order__date) as Month,monthname(order__date) as Month_Name ,round(sum(sales_amount),2) as Total_Sales
from adventureworks.salesmerged 
group by year(order__date),month(order__date),month_name 
order by year,month;

call Month_Wise_Sales(2011); #input Year


#8.Show yearwise Sales
select year(order__date) as year,round(sum(sales_amount),2) as Total_Sales 
from adventureworks.salesmerged group by Year(order__date) order by year;

#9.Show Monthwise sales
select year(order__date) as Year,month(order__date) as Month,monthname(order__date) as Month_Name ,round(sum(sales_amount),2) as Total_Sales
from adventureworks.salesmerged 
group by year(order__date),month(order__date),month_name 
order by year,month;

#10.Show Quarterwise sales
select quarter(order__date) as Quarter,round(sum(sales_amount),2) as Total_Sales 
from adventureworks.salesmerged group by Quarter(Order__Date) order by quarter;

select Quarter,round(sum(sales_amount),2) as Total_Sales 
from adventureworks.salesmerged group by Quarter order by quarter;

#11.Show Salesamount and Productioncost together
select year(order__date) Year,round(sum(sales_amount),2) as Total_Sales,round(sum(Production_Cost),2) as Total_ProductionCost
from adventureworks.salesmerged group by year(order__date) order by year;

select year(order__date) Year,round(sum(sales_amount),2) as Total_Sales,round(sum(Production_Cost),2) as Total_ProductionCost,
round(sum(profit),2) as Total_Profit
from adventureworks.salesmerged group by year(order__date) order by year;

#12.Above one with month and profit

select year(order__date) Year,Month,MonthName,round(sum(sales_amount),2) as Total_Sales,round(sum(Production_Cost),2) as Total_ProductionCost,
round(sum(profit),2) as Total_Profit
from adventureworks.salesmerged group by year(order__date),MonthName,Month order by year,month;

#13. Show profit ratio year wise quarter wise then monthwise with sales and profit values.
with profit as(
select year(order__date) as Year,quarter(order__date) as Quarter,monthname(order__date) as Month_Name,Month,
round(sum(sales_amount),2) as Total_Sales,round(sum(profit),2) as Total_Profit,concat(round((sum(profit)/sum(sales_amount))*100),"%") as Profit_Ratio
from adventureworks.salesmerged group by year(order__date) ,quarter(order__date) ,monthname(order__date),month
order by year,quarter,month)
select Year,Quarter,Month_Name,Total_Sales,Total_Profit,Profit_Ratio
from profit;

#14. Show countrywise sales;
select SalesTerritoryCountry,concat("$",round(sum(sales_amount),2)) as Total_Sales
from adventureworks.salesmerged s inner join adventureworks.dimsalesterritory st on s.SalesTerritoryKey=st.SalesTerritoryKey
group by SalesTerritoryCountry order by total_sales desc;

#15.Show categorywise & sub-category wise sales
select EnglishProductCategoryName,EnglishProductSubcategoryName,round(sum(Sales_Amount),2) as Total_Sales
from adventureworks.salesmerged s inner join adventureworks.dimproduct p on s.ProductKey=p.ProductKey
inner join adventureworks.dimproductsubcategory ps on p.ProductSubcategoryKey=ps.ProductSubcategoryKey
inner join adventureworks.dimproductcategory pc on ps.ProductCategoryKey=pc.ProductCategoryKey
group by EnglishProductCategoryName,EnglishProductSubcategoryName
order by EnglishProductCategoryName,total_sales desc;

#16. Show rankwise sub-category
select EnglishProductSubcategoryName,round(sum(sales_amount),2) as Total_Sales, 
dense_rank() over ( order by sum(Sales_Amount) desc) as Drank
from adventureworks.salesmerged s inner join adventureworks.dimproduct p on s.ProductKey=p.ProductKey
inner join adventureworks.dimproductsubcategory ps on p.ProductSubcategoryKey=ps.ProductSubcategoryKey
group by EnglishProductSubcategoryName;


#17. Compare sales qurater wise every year .
select Year,Quarter,round(sum(sales_amount),2) as Total_Sales ,lag(round(sum(sales_amount),2),1,0) over (order by year,Quarter) Last_quarter  from adventureworks.salesmerged
group by year,quarter;

#18. Show percentage growth too in above question.
with running as(
select Year,Quarter,round(sum(sales_amount),2) as Total_Sales,lag(round(sum(sales_amount),2),1,0) over (order by Year,Quarter) as LastQtr_Sales
from adventureworks.salesmerged group by year,quarter)
select *,concat(round(((total_sales-LastQtr_Sales)/lastqtr_sales)*100,2),"%") as Percentage_Growth from running;

#19. Show top 15 products as per sales.
select EnglishProductName,round(sum(Sales_Amount),2) as Total_Sales
from adventureworks.salesmerged s inner join adventureworks.dimproduct p on s.ProductKey=p.ProductKey
group by EnglishProductName
order by Total_sales desc
limit 15;

with rk as(
select EnglishProductName,round(sum(sales_amount),2) as Total_Sales,
dense_rank() over (order by sum(Sales_Amount) desc) as Rank_
from adventureworks.salesmerged s inner join adventureworks.dimproduct p on
s.ProductKey=p.ProductKey
group by EnglishProductName
order by Rank_ )
select EnglishProductName,Total_Sales from rk where rank_<=15;

#20. Do above with stored Procedures.
call topnproduct(10);

#21. Show the target audience as per salary group
select YearlyIncome,round(sum(sales_amount),2) as Total_Sales,count(OrderQuantity) as Quantity_Ordered
from adventureworks.salesmerged s inner join adventureworks.dimcustomer c on s.CustomerKey=c.CustomerKey
group by YearlyIncome order by total_sales desc;

#22.Show count of customers as per their commute distance.
select CommuteDistance,count(c.CustomerKey) as No_Of_Customers
from adventureworks.salesmerged s inner join adventureworks.dimcustomer c on s.CustomerKey=c.CustomerKey
group by CommuteDistance order by No_Of_Customers desc;

#23.Show Percentage of customers as per their commute distance.
select CommuteDistance,concat(round((count(c.CustomerKey)/(select count(customerkey) as total from adventureworks.salesmerged))*100,2),"%") 
as Percentage_Of_Customers
from adventureworks.salesmerged s inner join adventureworks.dimcustomer c on s.CustomerKey=c.CustomerKey
group by CommuteDistance order by Percentage_of_customers desc;




