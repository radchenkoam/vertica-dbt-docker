
  

  
  create or replace view "boston_crimes"."dbt"."stg_offense_codes" as (
    select
  code,
  name as offense_name
from "boston_crimes"."dbt"."offense_codes"
  );

