#Script That allow to save the user information from AD to an excel sheet.

$objExcel = new-object -comobject excel.application 
$objExcel.Visible = $true 
$UserWorkBook = $objExcel.Workbooks.Open('c:\exel\updateuser.xlsx')
$UserWorksheet = $UserWorkBook.Worksheets.Item(1)
$intRow =2


$alluser = get-aduser -SearchBase "OU=thisis,DC=an,DC=exemple" -filter *
Foreach($user in $alluser)
{
$nom = get-aduser $user -properties name | %{$_.name} 
$UserWorksheet.Cells.Item($intRow, 1) = "$nom"


$title = get-aduser $user -properties title | %{$_.title}
$UserWorksheet.Cells.Item($intRow, 2) = "$title"

$officephone = get-aduser $user -properties officephone | %{$_.officephone} 
$UserWorksheet.Cells.Item($intRow, 3)="$officephone" 

$mobilephone = get-aduser $user -properties mobilephone | %{$_.mobilephone}
$UserWorksheet.Cells.Item($intRow, 4) = "$mobilephone"

$office = get-aduser $user -properties office | %{$_.office}
 $UserWorksheet.Cells.Item($intRow, 5)="$office"

$department = get-aduser $user -properties department |%{$_.department}  
$UserWorksheet.Cells.Item($intRow, 6)="$department"

$email = get-aduser $user -properties emailaddress | %{$_.emailaddress}
$UserWorksheet.Cells.Item($intRow, 7)="$email"

 $intRow++
}

$UserWorkBook.Save()
 $objExcel.Quit()
