select
  code,
  name as offense_name
from {{ ref('offense_codes') }}
