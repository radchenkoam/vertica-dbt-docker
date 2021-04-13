
  

  
  create or replace view "boston_crimes"."dbt"."stg_crime" as (
    select
  incident_number as incident_id,
  offense_code,
  offense_code_group,
  offense_description,
  district,
  reporting_area,
  shooting,
  occurred_on_date,
  year,
  month,
  day_of_week,
  hour,
  ucr_part,
  street,
  lat,
  long,
  location
from dbt.crime
  );

