using namespace Microsoft.Azure.Commands.Profile.Models
$publicFunctions = @()
$PublicFunctions = foreach ($ScriptPathItem in 'Private','Public','Classes','Helpers') {
    $ScriptSearchFilter = [io.path]::Combine($PSScriptRoot, $ScriptPathItem, '*.ps1')
    Get-ChildItem -Recurse -Path $ScriptSearchFilter -Exclude '*.Tests.ps1' -ErrorAction SilentlyContinue | 
        Foreach-Object {
            . $PSItem
            if ($ScriptPathItem -eq 'Public') {
                $PSItem.BaseName
            }
        }
}
Export-ModuleMember $PublicFunctions

#Enable consistencylevel Eventual
#BUG: Remove when this is resolved: https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/513
Write-Host -Fore DarkCyan "JustinGrote GraphExtensions NOTE: This module automatically sets ConsistencyLevel to eventual to enable filters to work correctly. To disable this, use Disable-MgEventualConsistencyDefault. See this issue for more detail: https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/513"
$GLOBAL:PSDefaultParameterValues['Get-Mg*:ConsistencyLevel'] = 'Eventual'