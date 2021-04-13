with crime as (
    select * from {{ ref('stg_crime') }}
),
offense_codes as (
    select * from {{ ref('stg_offense_codes') }}
),
final as (
    select
      crime.incident_id,
      offense_codes.offense_name,
      crime.offense_code_group,
      crime.offense_description,
      crime.district,
      crime.reporting_area,
      crime.shooting,
      crime.occurred_on_date,
      crime.year,
      crime.month,
      crime.day_of_week,
      crime.hour,
      crime.ucr_part,
      crime.street,
      crime.lat,
      crime.long,
      crime.location
    from crime
      left join offense_codes using (offense_code)
)
select * from final
