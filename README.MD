# Powershell SDK for Microsoft Graph Extensions

These are some extensions for the [Powershell SDK for Microsoft Graph](https://github.com/microsoftgraph/msgraph-sdk-powershell). It is hoped these extensions make their way into the main module eventually.

## Features
- **Enables Eventual Consistency** - EventualConsistency is required for search parameters to work, however you have to remember to specify a switch to do it or the filters do nothing. I think that's dumb so I enabled it by default.
- **Connect-MgGraphAz** - Authenticates to Microsoft Graph using an existing Az module context for single sign on. Handles key refresh via the -HttpPipelinePrepend parameter
- **Get-MgManagedIdentity** - Managed Identities such as those used for Azure functions are hidden by default from Service Principal Searches for some reason, this exposes them.
- **Get-MgO365ServicePrincipal** - Provides a curated list of service principals that represent O365 services like Exchange or Teams, useful when you need to grant a service principal rights to interact with these services.
- **Get-MgAppRole** - Retrieves the app roles of a service principal, used for assigning rights to applications.
