%% Amazon Route 53

-module(erlcloud_route53).

-export([describe_zones/0, describe_zones/1,
         describe_zones/2, describe_zones/3,
         describe_zones/4]).

-export([describe_resource_sets/1, describe_resource_sets/2,
         describe_resource_sets/3, describe_resource_sets/4,
         describe_resource_sets/5, describe_resource_sets/6]).

-export([describe_delegation_sets/0, describe_delegation_sets/1,
         describe_delegation_sets/2, describe_delegation_sets/3]).

-include_lib("erlcloud/include/erlcloud.hrl").
-include_lib("erlcloud/include/erlcloud_aws.hrl").
-include_lib("erlcloud/include/erlcloud_route53.hrl").

-define(API_VERSION, "2013-04-01").
-define(DEFAULT_MAX_RECORDS, 20).
-define(DESCRIBE_ZONES_PATH, "/ListHostedZonesResponse/HostedZones/HostedZone").
-define(DESCRIBE_ZONE_IS_TRUNCATED, "/ListHostedZonesResponse/IsTruncated").
-define(DESCRIBE_ZONE_NEXT_MARKER, "/ListHostedZonesResponse/NextMarker").
-define(DESCRIBE_RS_PATH,
        "/ListResourceRecordSetsResponse/ResourceRecordSets/ResourceRecordSet").
-define(DESCRIBE_RS_IS_TRUNCATED,
        "/ListResourceRecordSetsResponse/IsTruncated").
-define(DESCRIBE_RS_NEXT_TYPE,
        "/ListResourceRecordSetsResponse/NextRecordType").
-define(DESCRIBE_RS_NEXT_NAME,
        "/ListResourceRecordSetsResponse/NextRecordName").
-define(DESCRIBE_RS_NEXT_ID,
        "/ListResourceRecordSetsResponse/NextRecordIdentifier").
-define(DESCRIBE_DS_PATH,
        "/ListReusableDelegationSetsResponse/DelegationSets/DelegationSet").
-define(DESCRIBE_DS_IS_TRUNCATED,
        "/ListReusableDelegationSetsResponse/IsTruncated").
-define(DESCRIBE_DS_NEXT_MARKER,
        "/ListReusableDelegationSetsResponse/NextMarker").

%% --------------------------------------------------------------------
%% @doc Describes all zones using default config
%% @end
%% --------------------------------------------------------------------
-spec(describe_zones() ->
             {{paged, string()}, list(aws_route53_zone())} |
             {ok, list(aws_route53_zone())} |
             {error, term()}).
describe_zones() ->
    describe_zones(erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes zones from a provided config set, or retrives additional
%% results from a truncated set
%% @end
%% --------------------------------------------------------------------
-spec(describe_zones(aws_config() | string()) ->
             {{paged, string()}, list(aws_route53_zone())} |
             {ok, list(aws_route53_zone())} |
             {error, term()}).
describe_zones(Config) when is_record(Config, aws_config) ->
    describe_zones(none, Config);
describe_zones(NextMarker) ->
    describe_zones(NextMarker, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes truncated zones with a specific config, and allows
%% continuation of truncated delegation set searchs
%% @end
%% --------------------------------------------------------------------
-spec(describe_zones(string() | integer(),
                     string() | aws_config()) ->
             {{paged, string()}, list(aws_route53_zone())} |
             {ok, list(aws_route53_zone())} |
             {error, term()}).
describe_zones(NextMarker, Config) when is_record(Config, aws_config) ->
    describe_zones(none, ?DEFAULT_MAX_RECORDS, NextMarker, Config);
describe_zones(NextMarker, DelegationSet) ->
    describe_zones(DelegationSet, ?DEFAULT_MAX_RECORDS, NextMarker).

%% --------------------------------------------------------------------
%% @doc Descibes zones using a a delegation set + provided config or limit
%% with continuation
%% @end
%% --------------------------------------------------------------------
-spec(describe_zones(Marker        :: string(),
                     string() | integer(),
                     AwsConfig     :: aws_config()) ->
             {{paged, string()}, list(aws_route53_zone())} |
             {ok, list(aws_route53_zone())} |
             {error, term()}).
describe_zones(NextMarker, DelegationSet, Config) when is_record(Config,
                                                                 aws_config) ->
    describe_zones(DelegationSet, ?DEFAULT_MAX_RECORDS, NextMarker, Config);
describe_zones(NextMarker, MaxItems, DelegationSet) ->
    describe_zones(DelegationSet, MaxItems,
                   NextMarker, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes zones using provided config, limit and delegation set
%% both next marker and delegation set are optional
%% @end
%% --------------------------------------------------------------------
-spec(describe_zones(DelegationSet :: string() | none,
                     MaxItems      :: integer(),
                     Marker        :: string() | none,
                     AwsConfig     :: aws_config()) ->
             {{paged, string()}, list(aws_route53_zone())} |
             {ok, list(aws_route53_zone())} |
             {error, term()}).
describe_zones(none, MaxItems, none, Config) ->
    do_describe_zones([{"maxitems", MaxItems}], Config);
describe_zones(DelegationSet, MaxItems, none, Config) ->
    do_describe_zones([{"maxitems", MaxItems}, {"DelegationSetId", DelegationSet}],
                      Config);
describe_zones(none, MaxItems, NextToken, Config) ->
    do_describe_zones([{"maxitems", MaxItems}, {"marker", NextToken}], Config);
describe_zones(DelegationSet, MaxItems, NextToken, Config) ->
    do_describe_zones([{"maxitems", MaxItems}, {"DelegationSetId", DelegationSet},
                       {"marker", NextToken}], Config).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using default config
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId :: string()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId) ->
    describe_resource_sets(ZoneId, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using provided
%% aws config or item limit
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId    :: string(),
                             integer() | aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId, AwsConfig) when is_record(AwsConfig, aws_config) ->
    do_describe_resource_sets(ZoneId, [{"maxitems", ?DEFAULT_MAX_RECORDS}],
                             AwsConfig);
describe_resource_sets(ZoneId, MaxItems) ->
    describe_resource_sets(ZoneId, MaxItems, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using provided
%% max items, name and/or types
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId    :: string(),
                             integer() | string(),
                             string()  | aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId, MaxItems, AwsConfig) when is_integer(MaxItems) ->
    do_describe_resource_sets(ZoneId, [{"maxitems", MaxItems}], AwsConfig);
describe_resource_sets(ZoneId, Name, AwsConfig) when is_record(AwsConfig,
                                                              aws_config) ->
    do_describe_resource_sets(ZoneId, [{"maxitems", ?DEFAULT_MAX_RECORDS},
                                      {"name", Name}], AwsConfig);
describe_resource_sets(Zone, Name, Type) ->
    describe_resource_sets(Zone, Name, Type, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using provided
%% config, limit and name OR by name and type with provide config
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId    :: string(),
                             Name      :: string(),
                             integer() | string(),
                             AwsConfig :: aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId, Name, MaxItems, AwsConfig) when is_integer(
                                                                MaxItems) ->
    do_describe_resource_sets(ZoneId, [{"maxitems", MaxItems},
                                      {"name", Name}], AwsConfig);
describe_resource_sets(ZoneId, Name, Type, AwsConfig) ->
    describe_resource_sets(ZoneId, Name, Type, ?DEFAULT_MAX_RECORDS, AwsConfig).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using provided
%% config, limit, name + type
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId    :: string(),
                             Name      :: string(),
                             Type      :: string(),
                             MaxItems  :: integer(),
                             AwsConfig :: aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId, Name, Type, MaxItems, AwsConfig) ->
    Params = [{"name", Name}, {"type", Type}, {"maxitems", MaxItems}],
    do_describe_resource_sets(ZoneId, Params, AwsConfig).

%% --------------------------------------------------------------------
%% @doc Describes resource sets for a specific zone_id using provided
%% config, limit, name, type and identifier
%% @end
%% --------------------------------------------------------------------
-spec(describe_resource_sets(ZoneId     :: string(),
                             Name       :: string(),
                             Type       :: string(),
                             Identifier :: string(),
                             MaxItems   :: integer(),
                             AwsConfig  :: aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {{paged, {string(), string()}},list(aws_route53_resourceset())} |
             {ok, list(aws_route53_resourceset())} |
             {error, term()}).
describe_resource_sets(ZoneId, Name, Type, Identifier, MaxItems, AwsConfig) ->
    Params = [{"name", Name}, {"type", Type},
              {"identifier", Identifier}, {"maxitems", MaxItems}],
    do_describe_resource_sets(ZoneId, Params, AwsConfig).

%% --------------------------------------------------------------------
%% @doc Describes delegation sets using default config + limit
%% @end
%% --------------------------------------------------------------------
-spec(describe_delegation_sets() ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {ok, list(aws_route53_delegation_set())} |
             {error, term()}).
describe_delegation_sets() ->
    describe_delegation_sets(?DEFAULT_MAX_RECORDS,
                             erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes delegation sets using provided config, or limit, or marker
%% @end
%% --------------------------------------------------------------------
-spec(describe_delegation_sets(integer() | string() | aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {ok, list(aws_route53_delegation_set())} |
             {error, term()}).
describe_delegation_sets(AwsConfig) when is_record(AwsConfig, aws_config) ->
    describe_delegation_sets(?DEFAULT_MAX_RECORDS, AwsConfig);

describe_delegation_sets(MaxItems) when is_integer(MaxItems) ->
    describe_delegation_sets(MaxItems, erlcloud_aws:default_config());
describe_delegation_sets(Marker) ->
    describe_delegation_sets(?DEFAULT_MAX_RECORDS, Marker,
                             erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describes delegation set using provided limit + config or Marker
%% @end
%% --------------------------------------------------------------------
-spec(describe_delegation_sets(MaxItems  :: integer(),
                               string() | aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {ok, list(aws_route53_delegation_set())} |
             {error, term()}).
describe_delegation_sets(MaxItems, AwsConfig) when is_integer(MaxItems),
                                                   is_record(AwsConfig,
                                                             aws_config) ->
    Params = [{"maxitems", MaxItems}],
    do_describe_delegation_sets(Params, AwsConfig);
describe_delegation_sets(MaxItems, Marker) when is_integer(MaxItems) ->
    describe_delegation_sets(MaxItems, Marker, erlcloud_aws:default_config()).

%% --------------------------------------------------------------------
%% @doc Describe delegation set using provided limit, marker + config
%% @end
%% --------------------------------------------------------------------
-spec(describe_delegation_sets(MaxItems  :: integer(),
                               Marker    :: string(),
                               AwsConfig :: aws_config()) ->
             {{paged, string()}, list(aws_route53_delegation_set())} |
             {ok, list(aws_route53_delegation_set())} |
             {error, term()}).
describe_delegation_sets(MaxItems, Marker, AwsConfig) ->
    Params = [{"maxitems", MaxItems}, {"marker", Marker}],
    do_describe_delegation_sets(Params, AwsConfig).

do_describe_delegation_sets(Params, AwsConfig) ->
    case route53_query(get, AwsConfig, "ListReusableDelegationSets", "/",
                       Params, "delegationset", ?API_VERSION) of
        {ok, Doc} ->
            Sets = xmerl_xpath:string(?DESCRIBE_DS_PATH, Doc),
            Fun = fun(Xml) ->
                          erlcloud_xml:get_text(?DESCRIBE_DS_NEXT_MARKER, Xml)
                  end,
            {maybe_get_marker(Doc, ?DESCRIBE_DS_IS_TRUNCATED, Fun),
             [extract_delegation_set(X) || X <- Sets]};
        Error ->
            Error
    end.

do_describe_resource_sets(ZoneId, Params, AwsConfig) ->
    Path = "/" ++ ZoneId ++ "/rrset",
    case route53_query(get, AwsConfig, "ListResourceRecordSets",
                       Path, Params, ?API_VERSION) of
        {ok, Doc} ->
            Sets = xmerl_xpath:string(?DESCRIBE_RS_PATH, Doc),
            Fun = fun(Xml) ->
                          case {erlcloud_xml:get_text(?DESCRIBE_RS_NEXT_NAME,
                                                      Xml, undefined),
                                erlcloud_xml:get_text(?DESCRIBE_RS_NEXT_TYPE,
                                                      Xml, undefined)} of
                              {undefined, undefined} ->
                                  erlcloud_xml:get_text(
                                    ?DESCRIBE_RS_NEXT_ID, Xml);
                              {NextName, NextType} ->
                                  {NextName, NextType}
                          end
                  end,
            {maybe_get_marker(Doc, ?DESCRIBE_RS_IS_TRUNCATED, Fun),
             [extract_resource_set(X) || X <- Sets]};
        {error, Reason} ->
            {error, Reason}
    end.

do_describe_zones(Params, Config) ->
    case route53_query(get, Config, "ListHostedZones", Params, ?API_VERSION) of
        {ok, Doc} ->
            Zones = xmerl_xpath:string(?DESCRIBE_ZONES_PATH, Doc),
            Fun = fun(Xml) ->
                          erlcloud_xml:get_text(?DESCRIBE_ZONE_NEXT_MARKER, Xml)
                  end,
            Result = {maybe_get_marker(Doc, ?DESCRIBE_ZONE_IS_TRUNCATED, Fun),
             [extract_zone(Z) || Z <- Zones]},
                Result;
        {error, Reason} ->
            {error, Reason}
    end.

maybe_get_marker(Xml, Path, Fun) ->
    case list_to_atom(erlcloud_xml:get_text(
                        hd(xmerl_xpath:string(Path, Xml)))) of
        false ->
            ok;
        true ->
            {paged, Fun(Xml)}
    end.

extract_geolocation(Rs) ->
    case xmerl_xpath:string("GeoLocation", Rs) of
        [] ->
            undefined;
        [Xml] ->
            #aws_route53_geolocation{
               continent_code = erlcloud_xml:get_text("ContinentCode", Xml),
               country_code = erlcloud_xml:get_text("CountryCode", Xml),
               subdivision_code = erlcloud_xml:get_text("SubdivisionCode", Xml)
              }
    end.

extract_resource_records(Rs) ->
    case xmerl_xpath:string("ResourceRecords/ResourceRecord", Rs) of
            [] ->
                undefined;
            Xml ->
                [erlcloud_xml:get_text("Value", X) || X <- Xml]
        end.

extract_alias_target(Rs) ->
    case xmerl_xpath:string("AliasTarget", Rs) of
        [] ->
            undefined;
        [Xml] ->
            #aws_route53_alias_target{
               hosted_zone_id = erlcloud_xml:get_text("HostedZoneId", Xml),
               dns_name = erlcloud_xml:get_text("DNSName", Xml),
               evaluate_target_health = list_to_atom(erlcloud_xml:get_text(
                                                       "EvaluateTargetHealth",
                                                       Xml))
              }
    end.

extract_delegation_set(Set) ->
    #aws_route53_delegation_set{
       id = erlcloud_xml:get_text("Id", Set),
       caller_reference = erlcloud_xml:get_text("CallerReference", Set,
                                                undefined),
       marker = erlcloud_xml:get_text("Marker", Set, undefined),
       name_servers = extract_name_servers(Set)}.

extract_name_servers(Set) ->
        case xmerl_xpath:string("NameServers/NameServer", Set) of
            [] ->
                undefined;
            Xml ->
                [erlcloud_xml:get_text(X) || X <- Xml]
        end.

extract_resource_set(Rs) ->
    #aws_route53_resourceset{
       name = erlcloud_xml:get_text("Name", Rs),
       type = erlcloud_xml:get_text("Type", Rs),
       set_identifier = erlcloud_xml:get_text("SetIdentifier", Rs, undefined),
       weight = erlcloud_xml:get_integer("Weight", Rs, undefined),
       region = erlcloud_xml:get_text("Region", Rs, undefined),
       failover = erlcloud_xml:get_text("Failover", Rs, undefined),
       health_check_id = erlcloud_xml:get_text("HealthCheckId", Rs, undefined),
       ttl = erlcloud_xml:get_integer("TTL", Rs, undefined),
       geo_location = extract_geolocation(Rs),
       resource_records = extract_resource_records(Rs),
       alias_target = extract_alias_target(Rs)
      }.

extract_zone(Zone) ->
    #aws_route53_zone{
       zone_id = erlcloud_xml:get_text("Id", Zone),
       name = erlcloud_xml:get_text("Name", Zone),
       private = list_to_atom(erlcloud_xml:get_text("Config/PrivateZone",
                                                    Zone, "undefined")),
       resourceRecordSetCount = erlcloud_xml:get_integer(
                                  "ResourceRecordSetCount", Zone),
       marker = erlcloud_xml:get_text("Marker", Zone, undefined),
       vpcs = extract_vpcs(Zone)
      }.

extract_vpcs(Zone) ->
    case xmerl_xpath:string("VPCs/VPC", Zone) of
        [] -> undefined;
        Xml ->
            [#aws_route53_vpc{
                vpc_id     = erlcloud_xml:get_text("VPCId", X),
                vpc_region = erlcloud_xml:get_text("VPCRegion", X)
               } || X <- Xml]
    end.


-spec route53_query(get | post, aws_config(), string(),
                    list({string(), string()}), string()) ->
    {ok, term()} | {error, term}.
route53_query(Method, Config, Action, Params, ApiVersion) ->
    route53_query(Method, Config, Action, "/", Params, ApiVersion).

-spec route53_query(get | post, aws_config(), string(), string(),
                    list({string(), string()}), string()) ->
    {ok, term()} | {error, term}.
route53_query(Method, Config, Action, Path, Params, ApiVersion) ->
    route53_query(Method, Config, Action,
                  Path, Params, "hostedzone", ApiVersion).

-spec route53_query(get | post, aws_config(), string(), string(),
                    list({string(), string()}), string(), string()) ->
    {ok, term()} | {error, term}.
route53_query(Method, Config, Action, Path, Params, Target, ApiVersion) ->
    QParams = [{"Action", Action}, {"Version", ApiVersion} | Params],
    erlcloud_aws:aws_request_xml4(Method, Config#aws_config.route53_host,
                                  Path, QParams, Target, Config).
