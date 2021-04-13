select
  code,
  name as offense_name
from {{ ref('raw_offense_codes') }}
