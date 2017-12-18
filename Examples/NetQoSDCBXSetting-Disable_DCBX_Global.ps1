Configuration DisableGlobalDCBX
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName NetQosDsc -ModuleVersion 1.0.0.0

    NetQoSDcbxSetting DisableGlobal
    {
        InterfaceAlias = 'Global'
        Willing = $false
    }
}
