#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psd1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetAdapterQoS.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetAdapterQoS.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
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
		$NetAdapterName
	)

    $configuration = @{
        Name = $NetAdapterName
    }

    $netAdapter = Get-NetAdapter -Name $NetAdapterName -ErrorAction SilentlyContinue

    if ($netAdapter)
    {
        if ((Get-NetAdapterQos -Name $NetAdapterName).Enabled)
        {
            $configuration.Add('Ensure','Present')
        }
        else
        {
            $configuration.Add('Ensure','Absent')
        }
    }
    else
    {
        throw $localizedData.NetAdapterNotFound    
    }

    return $configuration
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER NoRestart
Parameter description

.PARAMETER Ensure
Parameter description
#>
function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
        [Parameter(Mandatory = $true)]
		[String]
		$NetAdapterName,

        [Parameter()]
        [Boolean]
        $NoRestart = $true,

		[ValidateSet('Present','Absent')]
        [String]
		$Ensure = 'Present'    
	)

    $netAdapter = Get-NetAdapter -Name $NetAdapterName -ErrorAction SilentlyContinue
    
    if ($netAdapter)
    {
        $params = @{
            Name = $NetAdapterName
            NoRestart = $NoRestart
        }

        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.EnableQoS
            $params.Add('Enabled',$true)
        }
        else
        {
            Write-Verbose -Message $localizedData.DisableQoS
            $params.Add('Enabled',$false)
        }

        Set-NetAdapterQos @params -Verbose
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER NoRestart
Parameter description

.PARAMETER Ensure
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
		$NetAdapterName,

        [Parameter()]
        [Boolean]
        $NoRestart = $true,

		[ValidateSet('Present','Absent')]
        [String]
		$Ensure = 'Present'   
	)

    $netAdapter = Get-NetAdapter -Name $NetAdapterName -ErrorAction SilentlyContinue
    
    if ($netAdapter)
    {
        $qosEnabled = Get-NetAdapterQoS -Name $NetAdapterName -Verbose

        if ($Ensure -eq 'Present')
        {
            if ($qosEnabled)
            {
                Write-Verbose -Message $localizedData.QoSEnabledNoAction
                return $true
            }
            else
            {
                Write-Verbose -Message $localizedData.QoSShouldBeEnabled
                return $false
            }
        }
        else
        {
            if ($qosEnabled)
            {
                Write-Verbose -Message $localizedData.QoSShouldBeDisabled
                return $true
            }
            else
            {
                Write-Verbose -Message $localizedData.QoSNotEnabledNoAction
                return $false
            }
        }
    }    
}

Export-ModuleMember -Function *-TargetResource
