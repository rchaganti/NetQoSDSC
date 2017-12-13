#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psd1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosPolicy.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename NetQosPolicy.psd1 `
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

.PARAMETER PriorityValue8021Action
Parameter description

.PARAMETER PolicyStore
Parameter description
#>
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	Param
	(
        [Parameter(Mandatory = $true)]
		[String]
		$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte]
        $PriorityValue8021Action,

        [Parameter(Mandatory = $true)]
        [String]
        $PolicyStore   
	)

    $configuration = @{
        Name = $Name
        PriorityValue8021Action = $PriorityValue8021Action
        PolicyStore = $PolicyStore
    }

    Write-Verbose -Message $localizedData.CheckQosPolicy
    $qosPolicy = Get-NetQosPolicy -Name $Name -PolicyStore $PolicyStore -ErrorAction SilentlyContinue

    if ($qosPolicy)
    {
        $configuration.Add('PriorityValue8021Action', $qosPolicy.PriorityValue8021Action)
        $configuration.Add('NetDirectPortMatchCondition', $qosPolicy.NetDirectPortMatchCondition)
        $configuration.Add('DSCPAction', $qosPolicy.DSCPAction)
        $configuration.Add('MinBandwidthWeightAction', $qosPolicy.MinBandwidthWeightAction)
        $configuration.Add('ThrottleRateActionBitsPerSecond', $qosPolicy.ThrottleRate)
        $configuration.Add('NetworkProfile', $qosPolicy.NetworkProfile)
        $configuration.Add('Precedence', $qosPolicy.Precedence)        
        if ($qosPolicy.PriorityValue8021Action -eq $PriorityValue8021Action)
        {            
            Write-Verbose -Message ($localizedData.QoSpolicyExists -f $Name, $PolicyStore)
            $configuration.Add('Ensure', 'Present')
        }
        else
        {
            Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferent8021 -f $Name, $PolicyStore)
            $configuration.Add('Ensure', 'Absent')   
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.QoSPolicyDoesNotExist -f $Name, $PolicyStore)
        $configuration.Add('Ensure', 'Absent')    
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

.PARAMETER PriorityValue8021Action
Parameter description

.PARAMETER PolicyStore
Parameter description

.PARAMETER NetworkProfile
Parameter description

.PARAMETER MatchCondition
Parameter description

.PARAMETER Precedence
Parameter description

.PARAMETER DSCPAction
Parameter description

.PARAMETER MinBandwidthWeightAction
Parameter description

.PARAMETER ThrottleRateActionBitsPerSecond
Parameter description

.PARAMETER NetDirectPortMatchCondition
Parameter description

.PARAMETER Ensure
Parameter description
#>
function Set-TargetResource
{
	[CmdletBinding()]
	Param
	(
        [Parameter(Mandatory = $true)]
		[String]
		$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte]
        $PriorityValue8021Action,

        [Parameter(Mandatory = $true)]
        [String]
        $PolicyStore,

        [Parameter()]
        [ValidateSet('All','Domain','Private','Public')]
        [String]
        $NetworkProfile = 'All',

        [Parameter()]
        [ValidateSet('Default','SMB','Cluster','NFS','LiveMigration','iSCSI','FCOE')]
        [String]
        $MatchCondition,

        [Parameter()]
        [ValidateRange(0,255)]
        [uInt32]
        $Precedence = 127,

        [Parameter()]
        [ValidateRange(0,63)]
        [Byte]
        $DSCPAction,

        [Parameter()]
        [ValidateRange(0,100)]
        [Byte]
        $MinBandwidthWeightAction,

        [Parameter()]
        [uint64]
        $ThrottleRateActionBitsPerSecond,
        
        [Parameter()]
        [uint16]
        $NetDirectPortMatchCondition,
        
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
	)

    #Parameter checks
    if ($NetDirectPortMatchCondition -and $MatchCondition)
    {
        throw $localizedData.NetDirectMatchConditionAreExclusive
    }

    if ($MatchCondition -eq 'FCOE' -and ($DSCPAction -or $MinBandwidthWeightAction -or $ThrottleRateActionBitsPerSecond))
    {
        throw $localizedData.FCOESelected
    }

    Write-Verbose -Message $localizedData.CheckQosPolicy
    $qosPolicy = Get-NetQosPolicy -Name $Name -PolicyStore $PolicyStore -ErrorAction SilentlyContinue

    if ($qosPolicy)
    {
        if ($Ensure -eq 'Present')
        {
            #Check other properties
            $setParams = @{
                Name = $Name
                PolicyStore = $PolicyStore
            }

            if ($PriorityValue8021Action -ne $qosPolicy.PriorityValue8021Action)
            {
                $setParams.Add('PriorityValue8021Action',$PriorityValue8021Action)
            }

            if ($NetworkProfile -ne $qosPolicy.NetworkProfile)
            {
                $setParams.Add('NetworkProfile', $NetworkProfile)
            }

            if ($Precedence -ne $qosPolicy.Precedence)
            {
                $setParams.Add('Precedence', $Precedence)
            }

            if ($NetDirectPortMatchCondition -and ($NetDirectPortMatchCondition -ne $qosPolicy.NetDirectPortMatchCondition))
            {
                $setParams.Add('NetDirectPortMatchCondition', $NetDirectPortMatchCondition)
            }

            if ($DSCPAction -and ($DSCPAction -ne $qosPolicy.DSCPAction))
            {
                $setParams.Add('DSCPAction', $DSCPAction)
            }

            if ($MinBandwidthWeightAction -and ($MinBandwidthWeightAction -ne $qosPolicy.MinBandwidthWeightAction))
            {
                $setParams.Add('MinBandwidthWeightAction', $MinBandwidthWeightAction)
            }

            if ($ThrottleRateActionBitsPerSecond -and ($ThrottleRateActionBitsPerSecond -ne $qosPolicy.ThrottleRate))
            {
                $setParams.Add('ThrottleRateActionBitsPerSecond', $ThrottleRateActionBitsPerSecond)
            }

            if ($setParams.Keys.Count -gt 2)
            {
                Write-Verbose -Message $localizedData.SetQoSPolicy
                Set-NetQosPolicy @setParams -Verbose
            }
        }
        else
        {
            Write-Verbose -Message $localizedData.RemoveQoSPolicy 
            Remove-NetQosPolicy -Name $Name -PolicyStore $PolicyStore -Verbose  
        }
    }
    else
    {
        Write-Verbose -Message $localizedData.CreateQoSPolicy
        $newParams = @{
            Name = $Name
            PolicyStore = $PolicyStore
            PriorityValue8021Action = $PriorityValue8021Action
            Precedence = $Precedence
            NetworkProfile = $NetworkProfile
        }

        switch ($MatchCondition)
        {
            'SMB' {
                $newParams.Add('SMB', $true)
            }

            'iSCSI' {
                $newParams.Add('iSCSI', $true)
            }

            'LiveMigration' {
                $newParams.Add('LiveMigration', $true)
            }

            'FCOE' {
                $newParams.Add('FCOE', $true)
            }

            'NFS' {
                $newParams.Add('NFS', $true)
            }

            'Cluster' {
                $newParams.Add('Cluster', $true)
            }

            'Default' {
                $newParams.Add('Default', $true)
            }
        }

        if ($NetDirectPortMatchCondition)
        {
            $newParams.Add('NetDirectPortMatchCondition', $NetDirectPortMatchCondition)
        }

        if ($MinBandwidthWeightAction)
        {
            $newParams.Add('MinBandwidthWeightAction', $MinBandwidthWeightAction)
        }

        if ($DSCPAction)
        {
            $newParams.Add('DSCPAction', $DSCPAction)
        }

        if ($ThrottleRateActionBitsPerSecond)
        {
            $newParams.Add('ThrottleRateActionBitsPerSecond', $ThrottleRateActionBitsPerSecond)
        }

        $null = New-NetQosPolicy @newParams -Verbose
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER PriorityValue8021Action
Parameter description

.PARAMETER PolicyStore
Parameter description

.PARAMETER NetworkProfile
Parameter description

.PARAMETER MatchCondition
Parameter description

.PARAMETER Precedence
Parameter description

.PARAMETER DSCPAction
Parameter description

.PARAMETER MinBandwidthWeightAction
Parameter description

.PARAMETER ThrottleRateActionBitsPerSecond
Parameter description

.PARAMETER NetDirectPortMatchCondition
Parameter description

.PARAMETER Ensure
Parameter description
#>
function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	Param
	(
        [Parameter(Mandatory = $true)]
		[String]
		$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3,4,5,6,7)]
        [Byte]
        $PriorityValue8021Action,

        [Parameter(Mandatory = $true)]
        [String]
        $PolicyStore,

        [Parameter()]
        [ValidateSet('All','Domain','Private','Public')]
        [String]
        $NetworkProfile = 'All',

        [Parameter()]
        [ValidateSet('Default','SMB','Cluster','NFS','LiveMigration','iSCSI','FCOE')]
        [String]
        $MatchCondition,

        [Parameter()]
        [ValidateRange(0,255)]
        [UInt32]
        $Precedence = 127,

        [Parameter()]
        [ValidateRange(0,63)]
        [Byte]
        $DSCPAction,

        [Parameter()]
        [ValidateRange(0,100)]
        [Byte]
        $MinBandwidthWeightAction,

        [Parameter()]
        [uint64]
        $ThrottleRateActionBitsPerSecond,
        
        [Parameter()]
        [Uint16]
        $NetDirectPortMatchCondition,
        
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
	)

    #Parameter checks
    if ($NetDirectPortMatchCondition -and $MatchCondition)
    {
        throw $localizedData.NetDirectMatchConditionAreExclusive
    }

    if ($MatchCondition -eq 'FCOE' -and ($DSCPAction -or $MinBandwidthWeightAction -or $ThrottleRateActionBitsPerSecond))
    {
        throw $localizedData.FCOESelected
    }

    Write-Verbose -Message $localizedData.CheckQosPolicy
    $qosPolicy = Get-NetQosPolicy -Name $Name -PolicyStore $PolicyStore -ErrorAction SilentlyContinue

    if ($qosPolicy)
    {
        if ($Ensure -eq 'Present')
        {
            if ($PriorityValue8021Action -ne $qosPolicy.PriorityValue8021Action)
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferent8021 -f $Name, $PolicyStore)
                return $false
            }

            if ($NetworkProfile -ne $qosPolicy.NetworkProfile)
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentNetProfile -f $Name, $PolicyStore)
                retutn $false
            }

            if ($Precedence -ne $qosPolicy.Precedence)
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentPrecedence -f $Name, $PolicyStore)
                retutn $false
            }

            if ($NetDirectPortMatchCondition -and ($NetDirectPortMatchCondition -ne $qosPolicy.NetDirectPortMatchCondition))
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentNetDirectPort -f $Name, $PolicyStore)
                retutn $false
            }

            if ($DSCPAction -and ($DSCPAction -ne $qosPolicy.DSCPAction))
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentDSCPAction -f $Name, $PolicyStore)
                return $false
            }

            if ($MinBandwidthWeightAction -and ($MinBandwidthWeightAction -ne $qosPolicy.MinBandwidthWeightAction))
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentMinBandwidthWeight -f $Name, $PolicyStore)
                return $false
            }

            if ($ThrottleRateActionBitsPerSecond -and ($ThrottleRateActionBitsPerSecond -ne $qosPolicy.ThrottleRate))
            {
                Write-Verbose -Message ($localizedData.QoSpolicyExistsWithDifferentThrottleRate -f $Name, $PolicyStore)
                return $false
            }
            
            Write-Verbose -Message $localizedData.QoSpolicyExistsNoAction
            return $true
        }
        else
        {
            Write-Verbose -Message $localizedData.QoSPolicyShouldNotExist
            return $false
        }
    }
    else
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.QoSPolicyDoesNotExist
            return $false
        }
        else
        {
            Write-Verbose -Message $localizedData.QoSPolicyDoesNotExistNoAction
            return $true            
        }  
    }
}

Export-ModuleMember -Function *-TargetResource
