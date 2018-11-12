$userstochange = Get-ADUser -SearchBase "OU=Utilisateurs,OU=CEI,DC=CEI,DC=LOCAL" -Filter {(Enabled -eq $true) -and (mail -like '*')} -Properties *
$routableDomain = "colonialelegance.com"
foreach ($usertochange in $userstochange) 
{
$userName = $usertochange.UserPrincipalName.Split('@')[0] 
$UPN = $userName + "@" + $routableDomain
$usertochange | Set-ADUser -UserPrincipalName $UPN
}
