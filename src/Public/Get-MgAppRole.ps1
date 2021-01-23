using namespace Microsoft.Graph.PowerShell.Models

function Get-MgAppRole {
    <#
    .SYNOPSIS
    Retrieves a list of Managed Identities within the organization
    .DESCRIPTION
    Managed identities are hidden by default from Get-MgServicePrincipal. This exposes them
    .NOTES
    This is a derived function from Get-MgServicePrincipal. All other parameters work the same as that function
    #>
    [CmdletBinding(DefaultParameterSetName='RoleId')]
    param(
        #Id of the ServicePrincipal that you want to fetch Ids for
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][Guid]$Id,
        #Filter by the displayname of the role. Wildcards are supported.
        [Parameter(ParameterSetName='Filter')][String]$DisplayName,
        #Filter by the unique ID of the AppRole. Exact IDs only.
        [Parameter(ParameterSetName='RoleId')][Guid]$RoleId,
        #Filter by the description of the role. Wildcards are supported.
        [Parameter(ParameterSetName='Filter')][String]$Description,
        #Filter by the value (short role name) of the role. Wildcards are supported.
        [Parameter(ParameterSetName='Filter')][String]$Value
    )

    #TODO: Invoke-GraphRequest to create more specific activity?
    process {
        $appRoles = (Get-MgServicePrincipal -ServicePrincipalId $Id).AppRoles
        if (-not $appRoles) {return}
        if ($RoleId) {
            return $appRoles.where{$PSItem.Id -eq $RoleId}
        }

        if ($DisplayName) {
            $appRoles = $approles.where{$PSItem.DisplayName -like $DisplayName}
        }

        if ($Description) {
            $appRoles = $approles.where{$PSItem.Description -like $DisplayName}
        }
        if ($Value) {
            $appRoles = $approles.where{$PSItem.Value -like $Value}
        }

        return $appRoles
    }
}