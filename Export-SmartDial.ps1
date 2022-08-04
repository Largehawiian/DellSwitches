function Export-SmartDial {
    param (
        [int]$NumberOfPorts,
        [int[]]$ExcludePorts,
        [int]$TrunkPort,
        [int]$StackNumber
    )
    $output = @()
    $output += [NSeries]::Configheader()
    $output += [NSeries]::TrunkPortHeader($TrunkPort, $StackNumber)
    $i = 0
    $config = foreach-object {
        do {
            $i++
            if ($ExcludePorts -contains $i -or $TrunkPort -contains $i) { continue }
            [NSeries]::new($i, $StackNumber, "General", "allowed vlan add 30 tagged", "1", "1", "1", "30")

        } until ($i -eq $NumberOfPorts)
    }

    $output += foreach ($i in $config) {
        [Nseries]::SmartDial($i)
    }

    return $output
}
