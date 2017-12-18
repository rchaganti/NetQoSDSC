Configuration NetQoSFlowControl
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName NetQoSDSC -ModuleVersion 1.0.0.0

    NetQoSFlowControl EnableP3
    {
        Id = 'Priority3'
        Priority = 3
        Enabled = $true
    }

    NetQoSFlowControl DisableRest
    {
        Id = 'RestPriority'
        Priority = @(0,1,2,4,5,6,7)
        Enabled = $false
    }
}
