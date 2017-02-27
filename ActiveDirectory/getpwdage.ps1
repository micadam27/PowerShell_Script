#requires -version 2.0

#Get-ADUserPwdExpiration.ps1
#Jeffery Hicks
#http://jdhitsolutions.com/blog
#http://twitter.com/JeffHicks

#Modified from original version posted at
#http://blogs.msdn.com/adpowershell/archive/2010/02/26/find-out-when-your-password-expires.aspx

#dot source this script to load the function and alias into your
#PowerShell session.

Import-Module ActiveDirectory

function Get-ADUserPwdExpiration{
#requires -version 2.0

[cmdletbinding()]

   Param ([Parameter(Mandatory=$true, 
   Position=0, 
   ValueFromPipeline=$true, 
   HelpMessage="Identity of the User Account")]
   [Alias("name")]
   [string] $accountIdentity)

     PROCESS {

     Trap {
      Write-warning "An error occured on this account"
      write-warning $accountObj
      #$accountobj | select *
      write-warning $_.exception.Message
      continue
     }

     $accountObj = Get-ADUser $accountIdentity -properties PasswordExpired, PasswordNeverExpires, PasswordLastSet
     #enable the following line for debugging
     #$accountobj | select *
     
     #verify an account was found
     
     if ($accountObj) {     
      #set some default values
      
      $NeverExpires=$False     
      #default value indicates the account has expired    
      [datetime]$ExpiresOn="1/1/0001"
      
      if ($accountObj.PasswordExpired) {
         $expired=$True
        } 
       else {
        $Expired=$False
      }
            
      #verify there is a PasswordLastSet value
      if ($accountObj.PasswordLastSet) {
         $pwdLastSet=$accountObj.PasswordLastSet
      }
      else {
        #password has likely never been set
        $pwdLastSet=$False
        [timespan]$passwordAge=0
        #Write-warning "password last set is null"
      }
      
       If ($pwdLastSet) { 
        #get password details
        
        #get password age
        [timespan]$passwordAge=(get-date) - $pwdLastSet
        
         if ($accountObj.PasswordNeverExpires) {          
          $NeverExpires=$True
          [datetime]$ExpiresOn="9/9/9999"
        } 
        else {
         #get dfl
          $maxPasswordAgeTimeSpan = $null
          $dfl = (get-addomain).DomainMode

           if ($dfl -ge 3) { 
              ## Greater than Windows2008 domain functional level

              $accountFGPP = Get-ADUserResultantPasswordPolicy $accountObj

              if ($accountFGPP -ne $null) {
                $maxPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge

              } 
              else {
                $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
               }

            } #if $dfl -ge 3 
             else {
              $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
            }

            if ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0) {
              write-warning "MaxPasswordAge is not set for the domain or is set to zero!"

            } else {
              
              $pwdLastSet=$accountObj.PasswordLastSet
              [datetime]$ExpiresOn=$pwdLastSet + $maxPasswordAgeTimeSpan
            }
          } #else get dfl
      }
      #Write a custom object to the pipeline
      new-object PSObject -Property @{
        Name=$accountObj.name
        DN=$accountObj.DistinguishedName
        SAM=$accountObj.SAMAccountName
        NeverExpires=$neverExpires
        Expired=$expired
        ExpiresOn=$expiresOn
        PasswordLastSet=$pwdLastSet
        PasswordAge=$passwordAge
        Enabled=$accountobj.Enabled
      }
     } #end If $accountobj
     else {
      write-warning "Failed to find a user account for $accountIdentity"
     }
    } #end Process

  } #end function
  
 Set-Alias gupe Get-ADUserPwdExpiration
