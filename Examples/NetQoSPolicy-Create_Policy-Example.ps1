Configuration NewNetQoSPolicy
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName NetQoSDSC -ModuleVersion 1.0.0.0

    NetQosPolicy SMB
    {
        Name = 'SMB'
        PriorityValue8021Action = 3
        PolicyStore = 'localhost'
        Ensure = 'Present'
    }
}
