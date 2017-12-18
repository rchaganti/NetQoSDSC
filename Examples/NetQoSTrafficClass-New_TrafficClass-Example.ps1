Configuration NewTrafficClass
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName NetQoSDSC -ModuleVersion 1.0.0.0

    NetQosTrafficClass SMB
    {
        Name = 'SMB'
        Algorithm = 'ETS'
        Priority = 3
        BandwidthPercentage = 50
        Ensure = 'Present'
    }
}
