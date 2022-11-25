Function Get-TeamsDeviceUsageDistributionSummary {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet(7, 30, 90, 180)]
        [Int]
        $ReportPeriod = 7,

        [Parameter()]
        [Switch]
        $IncludeNonLicensedUser
    )

    if (!(Get-AccessToken)) {
        SayError 'No access token is found in the session. Run the New-AccessToken command first to acquire an access token.'
        Return $null
    }
	$null = Update-AccessToken
	$AccessToken = (Get-AccessToken).access_token

    try {
        $uri = "https://graph.microsoft.com/beta/reports/getTeamsDeviceUsageDistributionUserCounts(period='D$($ReportPeriod)')"
        if ($IncludeNonLicensedUser) {
            $uri = "https://graph.microsoft.com/beta/reports/getTeamsDeviceUsageDistributionTotalUserCounts(period='D$($ReportPeriod)')"
        }

        $result = (Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization = "Bearer $AccessToken" } -ContentType 'application/json' -ErrorAction Stop)
        $null = $result -match '(.*)Report Refresh Date'
        $result = ($result -replace $Matches[1], '') | ConvertFrom-Csv
        return $result
    }
    catch {
        SayError $_.Exception.Message
        return $null
    }
}