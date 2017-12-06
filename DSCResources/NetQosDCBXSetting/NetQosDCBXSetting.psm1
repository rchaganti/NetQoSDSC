#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosDCBXSetting.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosDCBXSetting.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER InterfaceAlias
Parameter description

.PARAMETER Willing
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
		$InterfaceAlias,

		[parameter(Mandatory = $true)]
		[Boolean]
		$Willing
	)

    $configuration = @{
        InterfaceAlias = $InterfaceAlias
        Willing = $(Get-NetQoSDCBXState -InterfaceAlias $InterfaceAlias -Verbose)
    }

    return $configuration
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER InterfaceAlias
Parameter description

.PARAMETER Willing
Parameter description
#>
function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]
		$InterfaceAlias,

		[parameter(Mandatory = $true)]
		[Boolean]
		$Willing
	)

    $currenState = $(Get-NetQoSDCBXState -InterfaceAlias $InterfaceAlias -Verbose)
    
    if ($currenState -ne $Willing)
    {
        Write-Verbose -Message $localizedData.SetWilling
        if ($InterfaceAlias -eq 'Global')
        {
            Write-Verbose -Message $localizedData.SetWillingGlobal
            Set-NetQosDcbxSetting -Willing $Willing -Verbose
        }
        else
        {
            Write-Verbose -Message ($localizedData.SetWillingInterface -f $InterfaceAlias)
            Set-NetQosDcbxSetting -InterfaceAlias $InterfaceAlias -Willing $Willing -Verbose
        }
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER InterfaceAlias
Parameter description

.PARAMETER Willing
Parameter description
#>
function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$InterfaceAlias,

		[parameter(Mandatory = $true)]
		[System.Boolean]
		$Willing
	)

    $currenState = $(Get-NetQoSDCBXState -InterfaceAlias $InterfaceAlias -Verbose)

    if ($currenState -ne $Willing)
    {
        Write-Verbose -Message $localizedData.WillingNotMatching
        return $false
    }
    else
    {
        Write-Verbose -Message $localizedData.WillingMatching
        return $true    
    }
}

Export-ModuleMember -Function *-TargetResource
