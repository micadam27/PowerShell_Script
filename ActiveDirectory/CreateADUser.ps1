#Import AD Module
Import-Module ActiveDirectory

#Create SMTP and SIP adresses Variables
$domain1 = "@departement-ti.com"
$domain2 = "@deti.ca"
$smtp1 ="SMTP:"
$smtp2 ="smtp:"
$sip ="SIP:"
$Domains = "departement-ti.com","deti.ca"


DO
{
#Ask if you want to clone a user. The answer MUST be "Y" or "N"
$CloneBool = Read-Host "Do you want to clone an existing user? [Y]es/[N]o"
}While(($CloneBool -ne "Y") -and ($CloneBool -ne "N"))

#If the answer was Y, then ask from from copy the settings
if($CloneBool = "Y")
{
$UserToClone = Read-Host "Which user would you like to clone? (Type its username)"

#Test if user exist
Get-ADUser $UserToClone
}

#Collect informations about the new user
$NewUserFirstName = Read-Host "What is the first name of the new user?"
$NewUserLastName = Read-Host "What is the last name of the new user?"
$NewUserUsername = Read-Host "What would be its login ?"
$NewUserPassword = Read-Host "What would be its Password?"
$NewUserSecurePassword = $NewUserPassword | ConvertTo-SecureString -AsPlainText -Force
$NewUserFullName = $NewUserFirstName + " " + $NewUserLastName

#Create the new User
New-ADUser -userprincipalname ($NewUserUsername + "@departement-ti.com") -name $NewUserFullName -SamAccountName $NewUserUsername -DisplayName  $NewUserFullName -GivenName $NewUserFirstName -Surname $NewUserLastName -Path "OU=User Accounts,OU=Accounts,OU=DTI,DC=dti,DC=local" -AccountPassword $NewUserSecurePassword -ChangePasswordAtLogon $False -Enabled $True 

#Ask what is the first part of the email address of the new user
$EmailStartWith = ""
do{
$EmailStartWith = Read-Host "What would be before the @ in his email address?"
}while($EmailStartWith -eq "")

#Create SMTP address and SIP address
$smtp1 = $smtp1 + $NewUserFirstName + $domain1
$smtp2 = $smtp2 + $NewUserFirstName + $domain2
$mailattribute = $NewUserFirstName + $domain1
$sip = $sip + $NewUserFirstName + $domain1

#Add SMTP and SIP address to mailbox
Get-ADUser -Identity $NewUserUsername | Set-ADUser -Add @{Proxyaddresses=$smtp1}
Get-ADUser -Identity $NewUserUsername | Set-ADUser -Add @{Proxyaddresses=$smtp2}
Get-ADUser -Identity $NewUserUsername | Set-ADUser -Add @{Proxyaddresses=$sip}

#Set email addres in AD
Set-ADUser $NewUserUsername -EmailAddress $mailattribute

#If you the user answered yes to clone user, then clone group
if($CloneBool = "Y")
{
Get-AdUser $UserToClone -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewUserUsername
}

Read-Host "Finished. Press enter to close."

