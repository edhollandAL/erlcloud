-record(aws_route53_delegation_set, {
          id               :: string(),
          caller_reference :: string(),
          marker           :: string(),
          name_servers     :: list(string())
         }).
-type(aws_route53_delegation_set() :: #aws_route53_delegation_set{}).

-record(aws_route53_vpc, {
          vpc_id     :: string(),
          vpc_region :: string()
         }).
-type(aws_route53_vpc() :: #aws_route53_vpc{}).

-record(aws_route53_zone, {
          zone_id                :: string(),
          name                   :: string(),
          private                :: true | false,
          resourceRecordSetCount :: integer(),
          marker                 :: string(),
          vpcs                   :: list(aws_route53_vpc())
         }).
-type(aws_route53_zone() :: #aws_route53_zone{}).

-record(aws_route53_geolocation, {
          continent_code   :: string(),
          country_code     :: string(),
          subdivision_code :: string()
         }).
-type(aws_route53_geolocation() :: #aws_route53_geolocation{}).

-record(aws_route53_alias_target, {
          hosted_zone_id :: string(),
          dns_name       :: string(),
          evaluate_target_health :: true | false
         }).
-type(aws_route53_alias_target() :: #aws_route53_alias_target{}).

-record(aws_route53_resourceset, {
       name :: string(),
       type :: string(),
       set_identifier :: string(),
       weight :: pos_integer(),
       region :: string(),
       failover :: string(),
       health_check_id :: string(),
       ttl :: pos_integer(),
       geo_location :: aws_route53_geolocation(),
       resource_records :: list(string()),
       alias_target :: aws_route53_alias_target()
      }).
-type(aws_route53_resourceset() :: #aws_route53_resourceset{}).
