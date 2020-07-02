######################################################################################
# Get TCP&UDP Network Daemons and Associated Processes
  
# Make a lookup table by process ID
$Processes = @{}
Get-Process -IncludeUserName | ForEach-Object {
    $Processes[$_.Id] = $_
}
  
  
# Query Listening TCP Daemons
echo "TCP Daemons"
Get-NetTCPConnection |
    Where-Object { $_.LocalAddress -eq "0.0.0.0" -and $_.State -eq "Listen" } |
    Select-Object LocalAddress,
        LocalPort,
        @{Name="PID";         Expression={ $_.OwningProcess }},
        @{Name="UserName";    Expression={ $Processes[[int]$_.OwningProcess].UserName }},
        @{Name="ProcessName"; Expression={ $Processes[[int]$_.OwningProcess].ProcessName }},
        @{Name="Path"; Expression={ $Processes[[int]$_.OwningProcess].Path }} |
    Sort-Object -Property LocalPort, UserName |
    Format-Table -AutoSize
  
  
# Query Listening UDP Daemons
echo "UDP Daemons"
Get-NetUDPEndpoint |
    Where-Object { $_.LocalAddress -eq "0.0.0.0" } |
    Select-Object LocalAddress,
        LocalPort,
        @{Name="PID";         Expression={ $_.OwningProcess }},
        @{Name="UserName";    Expression={ $Processes[[int]$_.OwningProcess].UserName }},
        @{Name="ProcessName"; Expression={ $Processes[[int]$_.OwningProcess].ProcessName }},
        @{Name="Path"; Expression={ $Processes[[int]$_.OwningProcess].Path }} |
    Sort-Object -Property LocalPort, UserName |
    Format-Table -AutoSize
  
#
