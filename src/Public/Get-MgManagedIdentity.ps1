using namespace Microsoft.Graph.PowerShell.Models

function Get-MgManagedIdentity {
    <#
    .SYNOPSIS
    Retrieves a list of Managed Identities within the organization
    .DESCRIPTION
    Managed identities are hidden by default from Get-MgServicePrincipal. This exposes them
    .NOTES
    This is a derived function from Get-MgServicePrincipal. All other parameters work the same as that function
    #>
    [CmdletBinding()]
    param()
    DynamicParam { Get-BaseParameters Get-MgServicePrincipal }

    process {
        [String]$managedIdentityFilter = "servicePrincipalType eq 'ManagedIdentity'"
        if ($PSBoundParameters.Filter) {
            $managedIdentityFilter = '(' + $PSBoundParameters.Filter + ') and ' + $managedIdentityFilter
        }

        $PSBoundParameters.Filter = $managedIdentityFilter

        mggraphinvoke {Get-MgServicePrincipal @PSBoundParameters}
    }
}