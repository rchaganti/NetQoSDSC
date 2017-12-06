#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosDSC.Helper.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosDSC.Helper.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

function Get-NetQoSFlowControlState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [Boolean]
        $DesiredState
    )

    Write-Verbose -Message $localizedData.CheckQoSCurrentState
    $flowControl = Get-NetQoSFlowControl -Priority $Priority -Verbose
    $currentState = $flowControl.Enabled | Select-Object -Unique

    if (($currentState.Count -gt 1) -or ($currentState -ne $DesiredState))
    {
        return $false
    }
    else
    {
        return $true    
    }
}

function Get-NetQoSDCBXState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $InterfaceAlias
    )

    Write-Verbose -Message $localizedData.CheckDcbxCurrentState
    if($InterfaceAlias -eq 'Global')
    {
        $currentState = (Get-NetQosDcbxSetting).Willing
    }
    else
    {
        $currentState = (Get-NetQosDcbxSetting -InterfaceAlias $InterfaceAlias).Willing
    }

    return $currentState
}
