#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosFlowControl.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosFlowControl.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Id
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER Enabled
Parameter description
#>
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
        [Parameter(Mandatory = $true)]
        [String]
        $Id,

        [Parameter(Mandatory = $true)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [Boolean]
        $Enabled
	)

    $configuration = @{
        Id = $Id
        Priority = $Priority
    }

    $qosCurrentState = Get-NetQoSFlowControlState -Priority $Priority -DesiredState $Enabled
    $configuration.Add('Enabled', $qosCurrentState)

    return $configuration
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Id
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER Enabled
Parameter description
#>
function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
        [Parameter(Mandatory = $true)]
        [String]
        $Id,

        [Parameter(Mandatory = $true)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [Boolean]
        $Enabled
	)
    
    $qosCurrentState = Get-NetQoSFlowControlState -Priority $Priority -DesiredState $Enabled
    
    if (-not $qosCurrentState)
    {
        Write-Verbose -Message $localizedData.SetQoSDesiredState
        Set-NetQosFlowControl -Priority $Priority -Enabled $Enabled -Verbose
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Id
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER Enabled
Parameter description
#>
function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
        [Parameter(Mandatory = $true)]
        [String]
        $Id,

        [Parameter(Mandatory = $true)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [Boolean]
        $Enabled
	)

    $qosCurrentState = Get-NetQoSFlowControlState -Priority $Priority -DesiredState $Enabled

    if ($qosCurrentState)
    {
        Write-Verbose -Message $localizedData.QoSInDesiredState
        return $true
    }
    else
    {
        Write-Verbose -Message $localizedData.QoSNotInDesiredState
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
