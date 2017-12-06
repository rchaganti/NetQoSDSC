#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosTrafficClass.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosTrafficClass.psd1 `
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

.PARAMETER Algorithm
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER BandwidthPercentage
Parameter description
#>
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
        [Parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[Parameter(Mandatory = $true)]
        [ValidateSet('ETS','Strict')]
        [System.String]
        $Algorithm,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,100)]
        [Byte]
        $BandwidthPercentage
	)

    $configuration = @{
        Name = $Name
    }

    Write-Verbose -Message $localizedData.GetTrafficClass
    $trafficClass = Get-NetQosTrafficClass -Name $Name -ErrorAction SilentlyContinue
    if($trafficClass)
    {
        Write-Verbose -Message $localizedData.TrafficClassFound
        $configuration.Add('Algorithm',$trafficClass.Algorithm)
        $configuration.Add('Priority',$trafficClass.Priority)
        $configuration.Add('BandwidthPercentage',$trafficClass.Bandwidth)
        $configuration.Add('Ensure','Present')
    }
    else
    {
        Write-Verbose -Message $localizedData.TrafficClassNotFound
        $configuration.Add('Ensure','Absent')
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

.PARAMETER Algorithm
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER BandwidthPercentage
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
		[System.String]
		$Name,

		[Parameter(Mandatory = $true)]
        [ValidateSet('ETS','Strict')]
        [System.String]
        $Algorithm,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,100)]
        [Byte]
        $BandwidthPercentage,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
	)

    $trafficClass = Get-NetQosTrafficClass -Name $Name -ErrorAction SilentlyContinue
    if ($trafficClass)
    {
        if ($Ensure -eq 'Present')
        {
            $setParams = @{
                Name = $Name
            }
            if ($trafficClass.Algorithm -ne $Algorithm)
            {
                $setParams.Add('Algorithm',$Algorithm)
            }

            if ($trafficClass.Bandwidth -ne $BandwidthPercentage)
            {
                $setParams.Add('BandwidthPercentage', $BandwidthPercentage)
            }

            if (Compare-Object -ReferenceObject $trafficClass.Priority -DifferenceObject $Priority -PassThru)
            {
                $setParams.Add('Priority', $Priority)
            }

            if ($setPArams.keys.count -ge 2)
            {
                Write-Verbose -Message $localizedData.UpdateTrafficClass
                Set-NetQosTrafficClass @setParams -Verbose
            }
        }
        else
        {
            Write-Verbose -Message $localizedData.RemoveTrafficClass
            Remove-NetQosTrafficClass -Name $Name -Verbose
        }
    }
    else
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.CreateTrafficClass
            $null = New-NetQosTrafficClass -Name $Name `
                                    -Priority $Priority `
                                    -BandwidthPercentage $BandwidthPercentage `
                                    -Algorithm $Algorithm -Verbose
        }
    }
    
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER Algorithm
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER BandwidthPercentage
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
		[System.String]
		$Name,

		[Parameter(Mandatory = $true)]
        [ValidateSet('ETS','Strict')]
        [System.String]
        $Algorithm,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte[]]
        $Priority,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,100)]
        [Byte]
        $BandwidthPercentage,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
	)

    Write-Verbose -Message $localizedData.GetTrafficClass
    $trafficClass = Get-NetQosTrafficClass -Name $Name -ErrorAction SilentlyContinue
    if ($trafficClass)
    {
        Write-Verbose -Message $localizedData.TrafficClassFound
        if ($Ensure -eq 'Present')
        {
            if ($trafficClass.Algorithm -ne $Algorithm)
            {
                Write-Verbose -Message $localizedData.AlgorithmNotMatching
                return $false
            }

            if ($trafficClass.Bandwidth -ne $BandwidthPercentage)
            {
                Write-Verbose -Message $localizedData.BandwidthPercentageNotMatching
                return $false
            }

            if (Compare-Object -ReferenceObject $trafficClass.Priority -DifferenceObject $Priority -PassThru)
            {
                Write-Verbose -Message $localizedData.PriorityNotMatching
                return $false
            }

            Write-Verbose -Message $localizedData.TrafficClassExistsNoAction
            return $true
        }
        else
        {
            Write-Verbose -Message $localizedData.TrafficClassShouldNotExist
            return $false    
        }
    }
    else
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.TrafficClassShouldExist
            return $false
        }
        else
        {
            Write-Verbose -Message $localizedData.TrafficClassDoesNotExistNoAction
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
