class NSeries {
    [string]$interface;
    [string]$StackNumber;
    [string]$mode;
    [string]$modeargs;
    [string]$LLDPServices;
    [string]$LLDPNotification;
    [string]$LLDPmed;
    [string]$VoiceVLAN;
    [string]$TrunkPort

    NSeries () {}

    NSeries ($interface,$StackNumber,$mode,$modeargs,$LLDPServices,$LLDPNotification,$LLDPmed,$VoiceVLAN)
    {
        
        $this.interface = "interface Gi$($StackNumber)/0/$($interface)"
        $this.mode =    "switchport mode $($mode)"
        $this.modeargs = "switchport $($mode) $($modeargs)"
        $this.LLDPServices = if ($LLDPServices) {"lldp tlv-select system-description system-capabilities"}
        $this.LLDPNotification =  if ($LLDPmed) {"lldp notification"}
        $this.LLDPmed = if ($LLDPmed) {"lldp med confignotification"}
        $this.VoiceVLAN = if ($VoiceVLAN) {"switchport voice vlan $($VoiceVLAN)"}
    }

    [array]SmartDial ($i)
    {
        $obj = @()
        $obj += "!"
        $obj += $i.interface
        $obj += $i.StackNumber
        $obj += $i.mode
        $obj += $i.modeargs
        $obj += $i.LLDPServices
        $obj += $i.LLDPNotification
        $obj += $i.LLDPmed
        $obj += $i.VoiceVLAN
        $obj += "Spanning-tree portfast"
        $obj += "exit"
        return $obj
        
    }

    [array]ConfigHeader ()
    {
        $obj = @()
        $obj += "!Current Configuration:"
        $obj += "!"
        $obj += "configure"
        $obj += "vlan 30"
        $obj += "exit"
        $obj += "Vlan 30"
        $obj += "Name SMARTDial"
        $obj += "exit"
        $obj += "switchport voice vlan"
        return $obj
    }

    [array]TrunkPortHeader ($TrunkPort,$StackNumber)
    {
        $obj = @()
        $obj += "!"
        $obj += "interface Gi$($StackNumber)/0/$($TrunkPort)"
        $obj += "Switchport mode general"
        $obj += "switchport general allowed vlan add 30 tagged"
        $obj += "no spanning-tree portfast"
        $obj += "Description TrunkPort"
        return $obj
    }
}

function Export-SmartDial {
    param (
        [int]$NumberOfPorts,
        [int[]]$ExcludePorts,
        [int]$TrunkPort,
        [int]$StackNumber
    )
    $output = @()
    $header = [NSeries]::new() ; $output += $header.ConfigHeader() ; $output += $header.TrunkPortHeader($TrunkPort,$StackNumber)
    $i = 0
$config = foreach-object {
    do {
        $i++
        if ($ExcludePorts -contains $i -or $TrunkPort -contains $i) { continue }
        [NSeries]::new($i,$StackNumber,"General","allowed vlan add 30 tagged","1","1","1","30")

    } until ($i -eq $NumberOfPorts)
}

$output += foreach ($i in $config){
    $i.SmartDial($i)
}

return $output
}
