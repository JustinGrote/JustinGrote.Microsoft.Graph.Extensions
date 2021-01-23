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
$PSDefaultParameterValues['Get-Mg*:ConsistencyLevel'] = 'Eventual'