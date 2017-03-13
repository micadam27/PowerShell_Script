Import-Module NTFSSecurity
$users = Get-ADUser -SearchBase "Path_Of_OU" -Filter *
foreach($user in $users)
{
$foldername = $user.GivenName + " " + $user.Surname
$path = "\\Path_To_Folder_Destination\" + $foldername
$folderexist = Test-Path $path
if($folderexist -eq $false)
{
New-Item $path -Type directory

}
Add-NTFSAccess -Path $path -Account $user.SamAccountName -AccessRights Modify
}
