Import-Module activedirectory 
$allmembers = Get-ADGroupMember YOUR_GROUP_TO_CLEAN
$disabledmembers = $allmembers | %{Get-ADUser -Identity $_.distinguishedName -Properties Enabled | ?{$_.Enabled -eq $false}}
Remove-ADGroupMember YOUR_GROUP_TO_CLEAN $disabledmembers
