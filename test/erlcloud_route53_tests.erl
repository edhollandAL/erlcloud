-module(erlcloud_route53_tests).
-include_lib("eunit/include/eunit.hrl").
-include("erlcloud_route53.hrl").
-include_lib("erlcloud/include/erlcloud_aws.hrl").

route53_test_() ->
    {foreach,
     fun setup/0,
     fun meck:unload/1,
     [fun describe_zone_tests/1,
      fun describe_resource_set_tests/1,
      fun describe_delegation_set_tests/1]
    }.

mocks() ->
    [mocked_zone1(), mocked_zone2(), mocked_zone3(), mocked_zone4(),
     mocked_resource_set1(), mocked_resource_set2(), mocked_resource_set3(),
     mocked_delegation_set()].

setup() ->
    meck:new(ECA = erlcloud_aws, [non_strict]),
    meck:expect(erlcloud_aws, default_config, 0, #aws_config{}),
    meck:expect(erlcloud_aws, aws_request_xml4, mocks()),
    [ECA].

mocked_delegation_set() ->
    {[get, '_', "/", [{"Action", "ListReusableDelegationSets"},
                      {"Version", '_'},
                      {"maxitems", 2}], "delegationset", '_'],
         make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListReusableDelegationSetsResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <DelegationSets>
      <DelegationSet>
         <Id>/delegationset/N1PA6795SAMPLE</Id>
         <CallerReference>unique value 1</CallerReference>
         <NameServers>
            <NameServer>ns-2042.awsdns-64.com</NameServer>
            <NameServer>ns-2043.awsdns-65.net</NameServer>
            <NameServer>ns-2044.awsdns-66.org</NameServer>
            <NameServer>ns-2045.awsdns-67.co.uk</NameServer>
         </NameServers>
      </DelegationSet>
      <DelegationSet>
         <Id>/delegationset/N1PA6796SAMPLE</Id>
         <CallerReference>unique value 2</CallerReference>
         <NameServers>
            <NameServer>ns-2046.awsdns-68.com</NameServer>
            <NameServer>ns-2047.awsdns-69.net</NameServer>
            <NameServer>ns-2048.awsdns-70.org</NameServer>
            <NameServer>ns-2049.awsdns-71.co.uk</NameServer>
         </NameServers>
      </DelegationSet>
   </DelegationSets>
   <IsTruncated>true</IsTruncated>
   <NextMarker>N1PA6797SAMPLE</NextMarker>
   <MaxItems>2</MaxItems>
</ListReusableDelegationSetsResponse>")}.

mocked_zone1() ->
    {[get, '_', "/", [{"Action", "ListHostedZones"},
                      {"Version", '_'},
                      {"maxitems", 20}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListHostedZonesResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <HostedZones>
      <HostedZone>
         <Id>/hostedzone/Z111111QQQQQQQ</Id>
         <Name>example.com.</Name>
         <CallerReference>MyUniqueIdentifier1</CallerReference>
         <Config>
            <Comment>This is my first hosted zone.</Comment>
            <PrivateZone>false</PrivateZone>
         </Config>
         <ResourceRecordSetCount>42</ResourceRecordSetCount>
      </HostedZone>
   </HostedZones>
   <IsTruncated>true</IsTruncated>
   <NextMarker>Z222222VVVVVVV</NextMarker>
   <MaxItems>1</MaxItems>
</ListHostedZonesResponse>
")}.

mocked_zone2() ->
    {[get, '_', "/", [{"Action", "ListHostedZones"},
                      {"Version", '_'},
                      {"maxitems", 20},
                      {"marker", "Z222222VVVVVVV"}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListHostedZonesResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <HostedZones>
      <HostedZone>
         <Id>/hostedzone/Z222222VVVVVVV</Id>
         <Name>example2.com.</Name>
         <CallerReference>MyUniqueIdentifier2</CallerReference>
         <Config>
            <Comment>This is my second hosted zone.</Comment>
            <PrivateZone>false</PrivateZone>
         </Config>
         <ResourceRecordSetCount>17</ResourceRecordSetCount>
      </HostedZone>
      <HostedZone>
         <Id>/hostedzone/Z2682N5HXP0BZ4</Id>
         <Name>example3.com.</Name>
         <CallerReference>MyUniqueIdentifier3</CallerReference>
         <Config>
            <Comment>This is my third hosted zone.</Comment>
            <PrivateZone>false</PrivateZone>
         </Config>
         <ResourceRecordSetCount>117</ResourceRecordSetCount>
      </HostedZone>
   </HostedZones>
   <Marker>Z222222VVVVVVV</Marker>
   <IsTruncated>true</IsTruncated>
   <NextMarker>Z333333YYYYYYY</NextMarker>
   <MaxItems>2</MaxItems>
</ListHostedZonesResponse>")}.

mocked_zone3() ->
    {[get, '_', "/", [{"Action", "ListHostedZones"},
                      {"Version", '_'},
                      {"maxitems", 9},
                      {"DelegationSetId","NZ8X2CISAMPLE"}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListHostedZonesResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <HostedZones>
      <HostedZone>
         <Id>/hostedzone/Z1D633PJN98FT9</Id>
         <Name>example1.com.</Name>
         <CallerReference>2014-10-01T11:22:14Z</CallerReference>
         <Config>
            <Comment>Delegation set id NZ8X2CISAMPLE</Comment>
         </Config>
         <ResourceRecordSetCount>4</ResourceRecordSetCount>
      </HostedZone>
      <HostedZone>
         <Id>/hostedzone/Z1I149ULENZ2PP</Id>
         <Name>example2.com.</Name>
         <CallerReference>2014-11-02T12:33:15Z</CallerReference>
         <Config>
            <Comment>Delegation set id NZ8X2CISAMPLE</Comment>
         </Config>
         <ResourceRecordSetCount>6</ResourceRecordSetCount>
      </HostedZone>
   </HostedZones>
   <IsTruncated>false</IsTruncated>
   <MaxItems>100</MaxItems>
</ListHostedZonesResponse>")}.

mocked_zone4() ->
    {[get, '_', "/", [{"Action", "ListHostedZones"},
                      {"Version", '_'},
                      {"maxitems", 42},
                      {"DelegationSetId","NZ8X2CISAMPLE"},
                      {"marker", "Z333333YYYYYYY"}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListHostedZonesResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <HostedZones>
      <HostedZone>
         <Id>/hostedzone/Z222222VVVVVVV</Id>
         <Name>example2.com.</Name>
         <VPCs>
            <VPC>
               <VPCId>FAKEVPCID</VPCId>
               <VPCRegion>us-west-1</VPCRegion>
            </VPC>
            <VPC>
               <VPCId>FAKEVPCID2</VPCId>
               <VPCRegion>eu-west-1</VPCRegion>
            </VPC>
         </VPCs>
         <CallerReference>MyUniqueIdentifier2</CallerReference>
         <Config>
            <Comment>This is my second hosted zone.</Comment>
            <PrivateZone>false</PrivateZone>
         </Config>
         <ResourceRecordSetCount>17</ResourceRecordSetCount>
      </HostedZone>
   </HostedZones>
   <Marker>Z333333YYYYYYY</Marker>
   <IsTruncated>true</IsTruncated>
   <NextMarker>Z4444444YYYYYYY</NextMarker>
   <MaxItems>42</MaxItems>
</ListHostedZonesResponse>")}.

mocked_resource_set1() ->
    {[get, '_', "/TESTID/rrset", [{"Action", "ListResourceRecordSets"},
                      {"Version", '_'},
                      {"maxitems", 1}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListResourceRecordSetsResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <ResourceRecordSets>
      <ResourceRecordSet>
         <Name>example.com.</Name>
         <Type>SOA</Type>
         <TTL>900</TTL>
         <ResourceRecords>
            <ResourceRecord>
               <Value>ns-2048.awsdns-64.net. hostmaster.awsdns.com. 1 7200 900 1209600 86400</Value>
            </ResourceRecord>
         </ResourceRecords>
      </ResourceRecordSet>
      <ResourceRecordSet>
         <Name>Alias</Name>
         <Type>TXT</Type>
         <AliasTarget>
            <HostedZoneId>HOSTEDZONE</HostedZoneId>
            <DNSName>DNS NAME</DNSName>
            <EvaluateTargetHealth>true</EvaluateTargetHealth>
         </AliasTarget>
         <HealthCheckId>HEALTHID</HealthCheckId>
      </ResourceRecordSet>
        <ResourceRecordSet>
         <Name>GEO</Name>
         <Type>MX</Type>
         <SetIdentifier>SETID</SetIdentifier>
         <GeoLocation>
            <ContinentCode>EU</ContinentCode>
            <CountryCode>GB</CountryCode>
            <SubdivisionCode>Wales</SubdivisionCode>
         </GeoLocation>
         <TTL>234</TTL>
         <ResourceRecords>
            <ResourceRecord>
               <Value>TEST GEO RECORD</Value>
            </ResourceRecord>
         </ResourceRecords>
      </ResourceRecordSet>
   </ResourceRecordSets>
   <IsTruncated>true</IsTruncated>
   <MaxItems>1</MaxItems>
   <NextRecordName>testdoc2.example.com</NextRecordName>
   <NextRecordType>NS</NextRecordType>
</ListResourceRecordSetsResponse>")}.

mocked_resource_set2() ->
    {[get, '_', "/TESTID/rrset", [{"Action", "ListResourceRecordSets"},
                                  {"Version", '_'},
                                  {"name", "example.com."},
                                  {"type", "NS"},
                                  {"maxitems", 20}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListResourceRecordSetsResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <ResourceRecordSets>
      <ResourceRecordSet>
         <Name>example.com.</Name>
         <Type>NS</Type>
         <TTL>172800</TTL>
         <ResourceRecords>
            <ResourceRecord>
               <Value>ns-2048.awsdns-64.com.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2049.awsdns-65.net.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2050.awsdns-66.org.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2051.awsdns-67.co.uk.</Value>
            </ResourceRecord>
         </ResourceRecords>
      </ResourceRecordSet>
   </ResourceRecordSets>
   <IsTruncated>false</IsTruncated>
   <MaxItems>10</MaxItems>
</ListResourceRecordSetsResponse>")}.

mocked_resource_set3() ->
    {[get, '_', "/TESTID/rrset", [{"Action", "ListResourceRecordSets"},
                                  {"Version", '_'},
                                  {"name", "example1.com."},
                                  {"type", "NS"},
                                  {"maxitems", 20}], "hostedzone", '_'],
     make_response("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListResourceRecordSetsResponse xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
   <ResourceRecordSets>
      <ResourceRecordSet>
         <Name>example.com.</Name>
         <Type>NS</Type>
         <TTL>172800</TTL>
         <SetIdentifier>SETID</SetIdentifier>
         <ResourceRecords>
            <ResourceRecord>
               <Value>ns-2048.awsdns-64.com.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2049.awsdns-65.net.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2050.awsdns-66.org.</Value>
            </ResourceRecord>
            <ResourceRecord>
               <Value>ns-2051.awsdns-67.co.uk.</Value>
            </ResourceRecord>
         </ResourceRecords>
      </ResourceRecordSet>
   </ResourceRecordSets>
   <IsTruncated>true</IsTruncated>
   <MaxItems>10</MaxItems>
   <NextRecordIdentifier>NEXTSETID</NextRecordIdentifier>
</ListResourceRecordSetsResponse>")}.

make_response(Xml) ->
    {ok, element(1, xmerl_scan:string(Xml))}.

describe_delegation_set_tests(_) ->
    [
     fun() ->
             Result = erlcloud_route53:describe_delegation_sets(2),
             Expected = {{paged, "N1PA6797SAMPLE"},
                         [#aws_route53_delegation_set{
                             id = "/delegationset/N1PA6795SAMPLE",
                             caller_reference = "unique value 1",
                             name_servers = ["ns-2042.awsdns-64.com",
                                             "ns-2043.awsdns-65.net",
                                             "ns-2044.awsdns-66.org",
                                             "ns-2045.awsdns-67.co.uk"]},
                          #aws_route53_delegation_set{
                             id = "/delegationset/N1PA6796SAMPLE",
                             caller_reference = "unique value 2",
                             name_servers = ["ns-2046.awsdns-68.com",
                                             "ns-2047.awsdns-69.net",
                                             "ns-2048.awsdns-70.org",
                                             "ns-2049.awsdns-71.co.uk"]}]},
             ?assertEqual(Expected, Result)
     end
    ].

describe_resource_set_tests(_) ->
    [
     fun() ->
             Result = erlcloud_route53:describe_resource_sets("TESTID", 1),
             Expected = {{paged, {"testdoc2.example.com", "NS"}},
                          [#aws_route53_resourceset{
                             name = "example.com.",
                             type = "SOA",
                             ttl = 900,
                             resource_records = ["ns-2048.awsdns-64.net. hostmaster.awsdns.com. 1 7200 900 1209600 86400"]},
                           #aws_route53_resourceset{
                              name = "Alias",
                              type = "TXT",
                              health_check_id = "HEALTHID",
                              alias_target = #aws_route53_alias_target{
                                                hosted_zone_id = "HOSTEDZONE",
                                                dns_name = "DNS NAME",
                                                evaluate_target_health = true}
                             },
                          #aws_route53_resourceset{
                             name = "GEO",
                             type = "MX",
                             set_identifier = "SETID",
                             ttl = 234,
                             geo_location = #aws_route53_geolocation{
                                              continent_code = "EU",
                                              country_code ="GB",
                                              subdivision_code = "Wales"},
                             resource_records = ["TEST GEO RECORD"]}
                          ]},
             ?assertEqual(Expected, Result)
     end,
     fun() ->
             Result = erlcloud_route53:describe_resource_sets("TESTID", "example.com.", "NS"),
             Expected = {ok, [#aws_route53_resourceset{
                                name = "example.com.",
                                type = "NS",
                                ttl = 172800,
                                resource_records = ["ns-2048.awsdns-64.com.",
                                                    "ns-2049.awsdns-65.net.",
                                                    "ns-2050.awsdns-66.org.",
                                                    "ns-2051.awsdns-67.co.uk."]
                                }]},
             ?assertEqual(Expected, Result)
     end,
     fun() ->
             Result = erlcloud_route53:describe_resource_sets("TESTID",
                                                             "example1.com.",
                                                             "NS"),
             Expected = {{paged, "NEXTSETID"},
                         [#aws_route53_resourceset{
                             name = "example.com.",
                             type = "NS",
                             ttl = 172800,
                             set_identifier = "SETID",
                             resource_records = ["ns-2048.awsdns-64.com.",
                                                 "ns-2049.awsdns-65.net.",
                                                 "ns-2050.awsdns-66.org.",
                                                 "ns-2051.awsdns-67.co.uk."]
                            }]},
             ?assertEqual(Expected, Result)
     end
    ].

describe_zone_tests(_) ->
    [
     fun() ->
             Result = erlcloud_route53:describe_zones(),
             Expected = {{paged, "Z222222VVVVVVV"},
                         [#aws_route53_zone{
                             zone_id = "/hostedzone/Z111111QQQQQQQ",
                             name    = "example.com.",
                             private = false,
                             resourceRecordSetCount = 42
                            }]},
             ?assertEqual(Expected, Result)
     end,
     fun() ->
             Result = erlcloud_route53:describe_zones("Z222222VVVVVVV"),
             Expected = {{paged, "Z333333YYYYYYY"},
                         [#aws_route53_zone{
                             zone_id = "/hostedzone/Z222222VVVVVVV",
                             name = "example2.com.",
                             private = false,
                             resourceRecordSetCount = 17},
                          #aws_route53_zone{
                             zone_id = "/hostedzone/Z2682N5HXP0BZ4",
                             name = "example3.com.",
                             private = false,
                             resourceRecordSetCount = 117}]},
             ?assertEqual(Expected, Result)
     end,
     fun() ->
             Result = erlcloud_route53:describe_zones(none, 9, "NZ8X2CISAMPLE"),
             Expected = {ok, [#aws_route53_zone{
                                  zone_id = "/hostedzone/Z1D633PJN98FT9",
                                  name = "example1.com.",
                                  resourceRecordSetCount = 4},
                               #aws_route53_zone{
                                  zone_id = "/hostedzone/Z1I149ULENZ2PP",
                                  name = "example2.com.",
                                  resourceRecordSetCount = 6}
                             ]},
             ?assertEqual(Expected, Result)
     end,
     fun() ->
             Result = erlcloud_route53:describe_zones("NZ8X2CISAMPLE", 42,
                                                      "Z333333YYYYYYY",
                                                      #aws_config{}),
             Expected = {{paged, "Z4444444YYYYYYY"},
                         [#aws_route53_zone{
                             zone_id = "/hostedzone/Z222222VVVVVVV",
                             name = "example2.com.",
                             private = false,
                             resourceRecordSetCount = 17,
                             vpcs = [#aws_route53_vpc{
                                        vpc_id = "FAKEVPCID",
                                        vpc_region = "us-west-1"
                                       },
                                     #aws_route53_vpc{
                                        vpc_id = "FAKEVPCID2",
                                        vpc_region = "eu-west-1"
                                       }]
                                 }]},
             ?assertEqual(Expected, Result)
     end
    ].
