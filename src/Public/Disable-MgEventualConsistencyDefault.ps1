function Disable-MgEventualConsistencyDefault {
    $Global:PSDefaultParameterValues.Remove('Get-Mg*:ConsistencyLevel')
}