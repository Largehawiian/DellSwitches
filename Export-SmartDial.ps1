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
