Configuration NetAdapterQoS
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName NetQoSDSC -ModuleVersion 1.0.0.0

    NetAdapterQoS EnableAdapterQoS
    {
        NetAdapterName = 'Storage1'
        Ensure = 'Present'
    }
}
