
#requires -module Az.Accounts,Microsoft.Graph.Authentication

function Connect-MgGraphAz {
    <#
    .SYNOPSIS
    Connect to Microsoft Graph using an "Az" powershell module context
    .DESCRIPTION
    This function saves you from logging in twice to both mggraph and the az powershell module by fetching a token using your azure context.
    .EXAMPLE
    Connect-MgGraphAz

    Connects with your current default Azure context
    .EXAMPLE
    $context = get-azcontext -ListAvailable | where name -match 'Development' | select -first 1
    Connect-MgGraphAz -DefaultProfile $context

    Connects to Microsoft Graph using the first profile in your context list that matches the name 'Development'
    .EXAMPLE
    get-azcontext -ListAvailable | where name -match 'Development' | select -first 1 | Connect-MgGraphAz

    Uses the pipeline to connect to Microsoft Graph using the first profile in your context list that matches the name 'Development'
    #>

    [CmdletBinding()]
    param (
        #The Az Module Context to use for the connection. You can get a list with Get-AzContext -ListAvailable. Note this parameter only accepts one context and if multiple are supplied it will only connect to the last one supplied
        [Parameter(ValueFromPipeline)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]$DefaultProfile,
        #Specify Process to use this token to authenticate just this process, or CurrentUser for all sessions started by this user
        [Microsoft.Graph.PowerShell.Authentication.ContextScope]$ContextScope,
        #Dont register the global refresh handler workaround. This is required if you want to use HttpPipelinePrepend
        [Switch]$NoRefresh,
        #Suppress the welcome messages
        [Switch]$Quiet
    )
    $ErrorActionPreference = 'Stop'

    $mgVarScope = if ($NoRefresh) {'Script'} else {'Global'}

    [Microsoft.Azure.Commands.Profile.Models.PSAccessToken]$tokenInfo = $(
        if ($DefaultProfile) {
            #Used for access token refresh
            Set-Variable '__MgAzContext' -Scope $mgVarScope -Value $DefaultProfile

            Get-AzAccessToken -DefaultProfile $DefaultProfile -ResourceUrl 'https://graph.microsoft.com'
        } else { 
            Get-AzAccessToken -ResourceUrl 'https://graph.microsoft.com'
        }
    )

    Set-Variable '__MgAzTokenExpires' -Scope $mgVarScope -Value $TokenInfo.ExpiresOn
    
    $connectMgParams = @{
        AccessToken = $tokenInfo.Token
    }
    if ($contextScope) {
        $connectMgParams.ContextScope = $ContextScope
    }

    $result = Connect-MgGraph @connectMgParams

    if ($result -eq 'Welcome To Microsoft Graph!') {
        if (-not $Quiet) {
            Write-Host -Fore Cyan "Microsoft Graph: Connected using Azure Context as $($tokenInfo.UserId) to Tenant $($tokenInfo.TenantId)." 
            if ($NoRefresh) {
                Write-Host -Fore Cyan "-NoRefresh was specified. You will need to run this command again after $($tokeninfo.ExpiresOn.LocalDateTime.ToString())"} else {
            }
        }
    } else {
        throw [InvalidOperationException]'Connect-MgGraph: Access token setup did not return the expected response.'
    }

    if (-not $NoRefresh) {
        $RefreshScriptBlock = {
            param ($req, $callback, $next)

            Write-Debug 'JGroteMgExtension: Checking if access token refresh required'
            #Check if global timer has expired and refresh if so
            if ($GLOBAL:__MgAzTokenExpires -lt [DateTime]::Now) {
                Write-Host -Fore DarkCyan "Token Expired! Refreshing before executing command."
                if ($GLOBAL:__MgAzContext) {
                    Connect-MgGraphAz -Quiet -DefaultProfile $GLOBAL:__MgAzContext
                } else {
                    Connect-MgGraphAz -Quiet
                }
            }
            return
        }

        if (-not $GLOBAL:PSDefaultParameterValues['*-Mg*:HttpPipelinePrepend']) {
            Write-Host -Fore DarkCyan "The HttpPipelinePrepend parameter now has a default that checks for refresh tokens. You should not use this parameter while using this module"
            $GLOBAL:PSDefaultParameterValues['*-Mg*:HttpPipelinePrepend'] = $RefreshScriptBlock
        }
    }


}