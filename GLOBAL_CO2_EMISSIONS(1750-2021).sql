                                                                                        --                REPLACING NULL VALUES             --



update global_co2_emission.dbo.emissions_by_country
set Total = 0 where Total is null

update global_co2_emission.dbo.emissions_by_country
set Coal = 0 where Coal is null

update global_co2_emission.dbo.emissions_by_country
set Oil = 0 where Oil is null

update global_co2_emission.dbo.emissions_by_country
set Gas = 0 where Gas is null

update global_co2_emission.dbo.emissions_by_country
set Cement = 0 where Cement is null

update global_co2_emission.dbo.emissions_by_country
set Flaring = 0 where Flaring is null

update global_co2_emission.dbo.emissions_by_country
set Other = 0 where Other is null

update global_co2_emission.dbo.emissions_by_country
set [Per Capita] = 0 where [Per Capita] is null


                                                                                 --             CONVERTING DATATYPE FROM STRING TO FLOAT           --

 alter  table global_co2_emission.dbo.emissions_by_country alter column Total float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column Coal float
	go
    alter  table global_co2_emission.dbo.emissions_by_country alter column Oil float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column Gas float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column Cement float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column Flaring float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column Other float
	go
	 alter  table global_co2_emission.dbo.emissions_by_country alter column [per capita] float
	go

  

                                                         --             CALCULATING THE EMISSION PERCENTAGES OF EACH SOURCE AND INSERTING THE VALUES INTO NEW TABLE           --


create table percentages
(country nvarchar(20), code nvarchar(20), continent nvarchar(20), year float, total float, coal_perc float, oil_perc float, gas_perc float, cement_perc float, flaring_perc float, other_perc float, per_capita float)

SET ANSI_WARNINGS OFF;
insert into global_co2_emission.dbo.percentages
(country, code, continent, year, total, coal_perc, oil_perc, gas_perc, cement_perc, flaring_perc, other_perc, per_capita)

--using the nullif function to avoid dividing by zero

select
Country,
Code,
Continent,
Year,
Total,
ROUND (Coal /nullif(Total,0)*100,2),
ROUND (Oil /nullif(Total,0)*100,2),
ROUND (Gas /nullif(Total,0)*100,2),
ROUND (Cement /nullif(Total,0)*100,2),
ROUND (Flaring /nullif(Total,0)*100,2),
ROUND (Other /nullif(Total,0)*100,2),
ROUND ([Per Capita] /nullif(Total,0)*100,2)

from global_co2_emission.dbo.emissions_by_country
SET ANSI_WARNINGS ON;

--removing nulls resulted from dividing

update global_co2_emission.dbo.percentages
set coal_perc = 0 where coal_perc is null

update global_co2_emission.dbo.percentages
set oil_perc = 0 where oil_perc is null

update global_co2_emission.dbo.percentages
set gas_perc = 0 where gas_perc is null

update global_co2_emission.dbo.percentages
set cement_perc = 0 where cement_perc is null

update global_co2_emission.dbo.percentages
set flaring_perc = 0 where flaring_perc is null

update global_co2_emission.dbo.percentages
set other_perc = 0 where other_perc is null

update global_co2_emission.dbo.percentages
set per_capita = 0 where per_capita is null



                                                                                  --             CREATING A TABLE TO SUM ALL TIME VALUES         --


create table alltime_sum
(country nvarchar(20), code nvarchar(20), continent nvarchar(10), total float, sum_coal float, sum_oil float, sum_gas float, sum_cement float, sum_flaring float, sum_other float, sum_percapita float)

SET ANSI_WARNINGS OFF;
insert into global_co2_emission.dbo.alltime_sum
(country, code, continent, total, sum_coal, sum_oil, sum_gas, sum_cement, sum_flaring, sum_other, sum_percapita)
select
Country,
Code,
Continent,
round(sum(total),2),
round(sum(Coal),2),
round(sum(Oil),2),
round(sum(Gas),2),
round(sum(Cement),2),
round(sum(Flaring),2),
round(sum(Other),2),
round(sum([Per Capita]),2)
 from
global_co2_emission.dbo.emissions_by_country
group by Country, Code, Continent
ORDER BY Country
 SET ANSI_WARNINGS ON; 



  
                          --              what source of emission is responsible for the highest level of total emissions of all time  (the correlation between different fossil fuel sources and co2 emission)               --


select 
 sum(Coal)as sumcoal,
 sum(Oil)as sumoil,
 sum(Gas)as sumgas,
 sum(Cement)as sumcement,
 sum(Flaring)as sumflaring,
 sum(Other)as sumother,
 sum([Per Capita])as sum_percapita,
(select
 max(emissions) from (values(sum(Coal)), (sum(Oil)), (sum(Gas)), (sum(Cement)), (sum(Flaring)), (sum(Other)), (sum([Per Capita]))  ) as highest_emittor(emissions) ) as maxemission
 from
 global_co2_emission.dbo.emissions_by_country




                                                         --                        countries where flaring emissions are the highest among all sources of emissions                    --

select
    Country,
    sum(Coal)as sumcoal,
    sum(Oil)as sumoil,
    sum(Gas)as sumgas,
    sum(Cement)as sumcement,
    sum(Flaring)as sumflaring,
    sum(Other)as sumother
from global_co2_emission.dbo.emissions_by_country
group by
    Country 
having 
    sum(Flaring)> sum(Coal) and sum(Flaring) > sum(Oil) and sum(Flaring) > sum(Gas) and sum(Flaring) > sum(Cement) 










