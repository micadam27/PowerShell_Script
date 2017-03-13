Get-AdUser "source_username" -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members "target_Username"
