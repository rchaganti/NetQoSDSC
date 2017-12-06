#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetQosDSC.Helper' `
                                                     -ChildPath 'NetQosDSC.Helper.psm1'))
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

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
        [parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[System.UInt16]
		$NetDirectPort,

		[parameter(Mandatory = $true)]
		[System.Byte]
		$PriorityValue8021Action
	)

    $returnValue = `
    @{
        Name = $Name
    }
    Write-Verbose -Message "Name: $Name"

    if($GetNetQosPolicy = Get-NetQosPolicy -Name $Name -ErrorAction SilentlyContinue)
    {
        $GetEnsure = 'Present'
        $returnValue.Add('NetDirectPort',$GetNetQosPolicy.NetDirectPort)
        $returnValue.Add('PriorityValue8021Action',$GetNetQosPolicy.PriorityValue8021Action)
        Write-Verbose -Message "NetDirectPort: $($GetNetQosPolicy.NetDirectPort)"
        Write-Verbose -Message "PriorityValue8021Action: $($GetNetQosPolicy.PriorityValue8021Action)"
    }
    else
    {
        $GetEnsure = 'Absent'
    }
    $returnValue.Add('Ensure',$GetEnsure)
    Write-Verbose -Message "Ensure: $GetEnsure"

    $returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[ValidateSet('Present','Absent')]
        [System.String]
		$Ensure = 'Present',

		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[System.UInt16]
		$NetDirectPort,

		[parameter(Mandatory = $true)]
		[System.Byte]
		$PriorityValue8021Action
	)

    switch($Ensure)
    {
        'Present'
        {
            if(Get-NetQosPolicy -Name $Name -ErrorAction SilentlyContinue)
            {
                Write-Verbose -Message "Setting NetQosPolicy $Name with NetDirectPort $NetDirectPort and PriorityValue8021Action $($PriorityValue8021Action -join ',')"
                Write-Verbose -Message "Cmdlet: Set-NetQosPolicy -Name $Name -NetDirectPortMatchCondition $NetDirectPort -PriorityValue8021Action $PriorityValue8021Action"
                Set-NetQosPolicy -Name $Name -NetDirectPortMatchCondition $NetDirectPort -PriorityValue8021Action $PriorityValue8021Action
            }
            else
            {
                Write-Verbose -Message "Creating NetQosPolicy $Name with NetDirectPort $NetDirectPort and PriorityValue8021Action $($PriorityValue8021Action -join ',')"
                Write-Verbose -Message "Cmdlet: New-NetQosPolicy -Name $Name -NetDirectPortMatchCondition $NetDirectPort -PriorityValue8021Action $PriorityValue8021Action"
                New-NetQosPolicy -Name $Name -NetDirectPortMatchCondition $NetDirectPort -PriorityValue8021Action $PriorityValue8021Action
            }
        }
        'Absent'
        {
            Write-Verbose -Message "Removing NetQosPolicy $Name"
            Write-Verbose -Message "Cmdlet: Remove-NetQosPolicy -Name $Name -Confirm:`$false"
            Remove-NetQosPolicy -Name $Name -Confirm:$false
        }
    }

    Write-Verbose -Message "Setting NetQosPolicy $Name after Set-TargetResource"
    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw 'failed'
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[ValidateSet('Present','Absent')]
        [System.String]
		$Ensure = 'Present',

		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[System.UInt16]
		$NetDirectPort,

		[parameter(Mandatory = $true)]
		[System.Byte]
		$PriorityValue8021Action
	)

    $TestTargetResource = Get-TargetResource -Name $Name -NetDirectPort $NetDirectPort -PriorityValue8021Action $PriorityValue8021Action

    $result = $true
    if($TestTargetResource.Ensure -eq $Ensure)
    {
        if($Ensure -eq 'Present')
        {
            $Settings = `
            @(
                'NetDirectPort'
                'PriorityValue8021Action'
            )
            foreach($Setting in $Settings)
            {
                if($TestTargetResource.$Setting -ne (Get-Variable -Name $Setting).Value)
                {
                    Write-Verbose -Message "$Setting is $($TestTargetResource.$Setting) but should be $((Get-Variable -Name $Setting).Value)"
                    $result = $false
                }
            }
        }
    }
    else
    {
        Write-Verbose -Message "Ensure is $($TestTargetResource.Ensure) but should be $Ensure"
        $result = $false
    }

    return $result
}


Export-ModuleMember -Function *-TargetResource
