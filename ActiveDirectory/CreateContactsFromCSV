Import-Module ActiveDirectory
$Users = Import-Csv "C:\Users\Administrator\Desktop\exportcontactmaximum.csv"
foreach($User in $Users){
  
    $Name = "$($User.GivenName) $($User.Surname)"
    $GivenName = $User.GivenName
    $Surname = $User.Surname
    $mobile = $User.mobile
    $Telephonenumber = $user.Telephonenumber
    $EmailAddress = $User.mail
    $Path = "OU=Contacts,OU=DTI,DC=dti,DC=local"
  
  New-ADObject -Type contact -Name $Name -Path "OU=Contacts,OU=DTI,DC=dti,DC=local" -OtherAttributes @{'GivenName'=$GivenName;'sn'=$Surname; 'mail'=$EmailAddress; 'Telephonenumber' = $Telephonenumber; 'mobile' = $mobile;}
}
