param (
    $FromDate = "2018-04-23T00:01",
    $ToDate = "2018-04-29T23:59",
    $apiKey = "" # super secret
)

$ErrorActionPreference = "Stop"

function GetLogs($page, $perPage){
    $header = @{
        "Authorization" = $apiKey;
        "Accept" = "application/json"
    }

    $sphost = "https://sitecore.api.e.sparkpost.com"
    $apicmd = "/api/v1/message-events?&from=$FromDate&to=$ToDate&page=$page&per_page=$perPage" ##events=delivery,injection,bounce,delay,policy_rejection,out_of_band,open,click,generation_failure,generation_rejection,spam_complaint,list_unsubscribe,link_unsubscribe,relay_delivery,relay_injection,relay_permfail,relay_rejection,relay_tempfail&from=$FromDate&to=$ToDate&page=$page&per_page=$perPage"

    $final = "$sphost$apicmd"

    $results = Invoke-RestMethod -Uri $final -Method Get -Headers $header

    return $results
}


    
Write-Host "Running GET message events for ..."

$paramPage = 1
$paramPerPage = 1000
    
$currentResults = GetLogs $paramPage $paramPerPage

$globalResults = @();

while ($currentResults.results.length -eq $paramPerPage) 
{
    $globalResults = $globalResults + $currentResults.results
        
    $paramPage += 1

    start-Sleep -s 5

    $currentResults = GetLogs $paramPage $paramPerPage
}

$globalResults = $globalResults + $currentResults.results

$globalResults | Select accept_language,binding,binding_group,campaign_id,customer_id,delv_method,event_id,friendly_from,geo_ip/city,geo_ip/country,geo_ip/latitude,geo_ip/longitude,geo_ip/region,ip_address,ip_pool,message_id,msg_from,msg_size,pathway,pathway_group,raw_rcpt_to,rcpt_meta/contact_id,rcpt_to,routing_domain,sending_ip,subaccount_id,subject,tdate,template_id,template_version,transmission_id,type,user_agent,timestamp,bounce_class,error_code,raw_reason,rcpt_meta/instance_id,rcpt_meta/message_id,rcpt_meta/target_language,rcpt_meta/test_value_index,reason,num_retries,queue_time,recv_method,fbtype,report_by,report_to | Export-CSV "emailcloud-detailedoutput.csv" -NoTypeInformation

Write-Host "Finished!"