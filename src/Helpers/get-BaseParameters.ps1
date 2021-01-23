#From https://github.com/PowerShell/PowerShell/issues/6585#issuecomment-379523326
using namespace System.Management.Automation
using namespace System.Management.Automation.Internal

function get-BaseParameters {
    <#
        .Synopsis
        Get the non-common parameters for a defined function
        .Description
        Useful for inheriting parameters in wrapper functions and formatting/passing them through.
        .Example
        . {
            function MyFunction
                dynamicparam {
                    Get-BaseParameters "Microsoft.PowerShell.Utility\Write-Host"
                }
            }
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BaseFunction
    )
    $BaseCommand = Get-Command $BaseFunction
    $CommonParameters = [CommonParameters].GetProperties().Name
    if ($BaseCommand) {
        $Dictionary = [RuntimeDefinedParameterDictionary]::new()
        foreach ($Parameter in $BaseCommand.Parameters.GetEnumerator()) {
            $Value = $Parameter.Value
            $Key = $Parameter.Key
            if ($Key -notin $CommonParameters) {
                $Parameter = [RuntimeDefinedParameter]::new(
                    $Key, $Value.ParameterType, $Value.Attributes)
                $Dictionary.Add($Key, $Parameter)
            }
        }
        return $Dictionary
    }
}