#Get Date postgres data and time enlapse calculation
$startTime = Get-Date

#Configure CIPP APi informations
Set-CIPPAPIDetails -CIPPClientID "<CIPP Client ID>" -CIPPClientSecret "<CIPP Client Secret>" -CIPPAPIUrl "<CIPP URL>" -TenantID "<Azure Tenant ID>"

#Create Users list
$licenceduserslist = @()

#Get all tenant in CIPP
$Customertenants = Get-CIPPTenants |select customerId,displayName

#Go through All tenant to extract users informations
foreach($Customertenant in $Customertenants)
{
    #Get the users MFA status
    $UsersMFAstatus = Get-CIPPMFAUsers $Customertenant.customerId | Where-Object { $_.AccountEnabled -eq 'True' -and $_.isLicensed -eq 'True' }
    #Get the users M365 licences details
    $licencedusers = Get-CIPPUsers -CustomerTenantID $Customertenant.customerId | Where-Object -Property accountEnabled -eq "true" |Where-Object { $_.LicJoined} | select id,displayName,mail,LicJoined
    #Get all users member of the exclude MFA group
    $excludegroupmembers = ((get-cippgroups $Customertenant.customerId | Where-Object -Property displayName -like "*ExcludeMFA").memberscsv).split(",")

    #Add the users to the list, then add the matching information for each of them
    foreach($licenceduser in $licencedusers)
    {
        #Get the users matching data for MFA status methods    
        $userMFARegistration = ($UsersMFAstatus | Where-Object -Property id -eq $licenceduser.id).MFARegistration
        $userMFACapable = ($UsersMFAstatus | Where-Object -Property id -eq $licenceduser.id).MFACapable
        $userMFAMethods = ($UsersMFAstatus | Where-Object -Property id -eq $licenceduser.id).MFAMethods
        #Add the matching data tu the current users's properties
        $licenceduser | Add-Member -MemberType NoteProperty -Name TenantID -Value $Customertenant.customerId
        $licenceduser | Add-Member -MemberType NoteProperty -Name TenantName -Value $Customertenant.displayName
        $licenceduser | Add-Member -MemberType NoteProperty -Name MFARegistration -Value $userMFARegistration
        $licenceduser | Add-Member -MemberType NoteProperty -Name MFACapable -Value $userMFACapable
        $licenceduser | Add-Member -MemberType NoteProperty -Name MFAMethods -Value $userMFAMethods
        #check if the user is member of then exclude MFA group
        $MemberOfExcludeMFAGroup = $excludegroupmembers -contains $licenceduser.mail
        #Add True or false to the property associated to exclude mfa membership
        $licenceduser | Add-Member -MemberType NoteProperty -Name MemberOfExcludeMFAGroup -Value $MemberOfExcludeMFAGroup
        #kepp track of were the script is, uncomment next line to have verbose
        #write-host  "User $($licenceduser.displayName) is completed"
    }
    #Add all users to the list before going to the next company
    $licenceduserslist += $licencedusers
    #kepp track of were the script is, uncomment next line to have verbose
    #write-host  "Tenant $($Customertenant.displayName) is completed"
}

#Décommenter pour afficher le resultat de la liste.
#$licenceduserslist


# --- End of  Data Collection ---

#uncomment the next 3 line to have verbose of time enlapse
#$endTime = Get-Date
#$duration = $endTime - $startTime
#Write-Host "User Data Colelction completed in $($duration.TotalMinutes.ToString("0.00")) minutes ($($duration.TotalSeconds.ToString("0.0")) seconds)."

# --- Adding Data to postgresql database ---

# Define connection string (DSN-less)
$connectionString = "Driver={PostgreSQL Unicode};Server=<Server IP>;Port=5432;Database=<DB Name>;Uid=<Username>;Pwd=<password>;SSLmode=require;SearchPath=<Schema Name>;"

# Create connection
$connection = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$connection.Open()

#Delete Command to clear database before adding informations
$deleteCommand = $connection.CreateCommand()
$deleteCommand.CommandText = "DELETE FROM <Schema Name>.<Table Name>"
$deleteCommand.ExecuteNonQuery()

#Go through each user, and add it's data to the database
foreach($licenceduser2 in $licenceduserslist)
{
    # Create command
    $command = $connection.CreateCommand()
    $command.CommandText = "INSERT INTO <Schema Name>.<Table Name> (id, displayname, mail, licjoined, tenantid, tenantname, mfaregistration, mfacapable, mfamethods, memberoffexcludemfagroup, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

    # Add parameters
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [Guid]$licenceduser2.id)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", $licenceduser2.displayName)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", $licenceduser2.mail)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", $licenceduser2.LicJoined)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [Guid]$licenceduser2.TenantID)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", $licenceduser2.TenantName)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [bool]$licenceduser2.MFARegistration)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [bool]$licenceduser2.MFACapable)))
    $pgArraymfamethod = '{' + ($licenceduser2.MFAMethods -join ',') + '}'
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", $pgArraymfamethod)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [bool]$licenceduser2.MemberOfExcludeMFAGroup)))
    $command.Parameters.Add((New-Object System.Data.Odbc.OdbcParameter("", [datetime]$startTime)))

    # Execute the add user query
    $command.ExecuteNonQuery()

    
}
# Close sql connection
$connection.Close()

# --- Your script ends here ---

#uncomment the next 3 line to have verbose of time enlapse
#$endTime = Get-Date
#$duration = $endTime - $startTime
#Write-Host "Script completed in $($duration.TotalMinutes.ToString("0.00")) minutes ($($duration.TotalSeconds.ToString("0.0")) seconds)."
