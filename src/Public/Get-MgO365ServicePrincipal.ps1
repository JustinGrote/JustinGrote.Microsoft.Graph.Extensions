using namespace Microsoft.Graph.PowerShell.Models

function Get-MgO365ServicePrincipal {
    <#
    .SYNOPSIS
    Retrieves a list of reserved service principals which provide roles for managing Office 365 services
    .DESCRIPTION
    There are some special service "well-known/builtin" service principals whose approles are used with Office 365. This convenience function returns only those
    .NOTES
    This is a derived function from Get-MgServicePrincipal. All other parameters work the same as that function
    #>
    [CmdletBinding()]
    param()
    DynamicParam { Get-BaseParameters Get-MgServicePrincipal }

    begin {
        $O365Principals = @(
            '00000007-0000-0ff1-ce00-000000000000' #Microsoft Exchange Online Protection
            '00000002-0000-0ff1-ce00-000000000000' #Office 365 Exchange Online
            '00000003-0000-0ff1-ce00-000000000000' #Office 365 SharePoint Online
            '00000003-0000-0000-c000-000000000000' #Microsoft Graph
            '00000004-0000-0ff1-ce00-000000000000' #Skype for Business Online
            '00000009-0000-0000-c000-000000000000' #Power BI Service
            '00000002-0000-0000-c000-000000000000' #Windows Azure Active Directory
            '00000012-0000-0000-c000-000000000000' #Microsoft Rights Management Services
        )
    }

    process {
        [String]$managedIdentityFilter = $O365Principals.foreach{
            "appId eq '$PSItem'"
        } -join ' or '
        if ($PSBoundParameters.Filter) {
            $managedIdentityFilter = '(' + $PSBoundParameters.Filter + ') and ' + $managedIdentityFilter
        }
        #Required for advanced queries
        $PSBoundParameters.ConsistencyLevel = 'Eventual'

        $PSBoundParameters.Filter = $managedIdentityFilter

        Get-MgServicePrincipal @PSBoundParameters
    }
}