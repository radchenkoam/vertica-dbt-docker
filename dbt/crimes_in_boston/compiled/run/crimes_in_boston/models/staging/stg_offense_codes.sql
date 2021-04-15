
  

  
  create or replace view "boston_crimes"."dbt"."stg_offense_codes" as (
    select
  CODE as OFFENSE_CODE,
  NAME as OFFENSE_NAME
from "boston_crimes"."dbt"."offense_codes"
  );

