
  

  
  create or replace view "boston_crimes"."dbt"."stg_crime" as (
    select
  INCIDENT_NUMBER as INCIDENT_ID,
  OFFENSE_CODE,
  OFFENSE_CODE_GROUP,
  OFFENSE_DESCRIPTION,
  DISTRICT,
  REPORTING_AREA,
  SHOOTING,
  OCCURRED_ON_DATE,
  YEAR,
  MONTH,
  DAY_OF_WEEK,
  HOUR,
  UCR_PART,
  STREET,
  Lat,
  Long,
  Location
from "boston_crimes"."dbt"."crime"
  );

