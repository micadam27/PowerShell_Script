# Script permettant d'importer les informations des users d'un excel vers l'AD (excel doit être présent sur le poste)
Import-Module ActiveDirectory

$objExcel = new-object -comobject excel.application 
$objExcel.Visible = $True 
$UserWorkBook = $objExcel.Workbooks.Open('c:\exel\userinfo.xlsx')
$UserWorksheet = $UserWorkBook.Worksheets.Item(1)
$intRow =2
do {

 $Name = $UserWorksheet.Cells.Item($intRow, 1).Value()
 $Titre = $UserWorksheet.Cells.Item($intRow, 2).Value()
 $telephone = $UserWorksheet.Cells.Item($intRow, 3).Value()
 $cellullaire = $UserWorksheet.Cells.Item($intRow, 4).Value()
 $Emplacement = $UserWorksheet.Cells.Item($intRow, 5).Value()
 $Service = $UserWorksheet.Cells.Item($intRow, 6).Value()
 $email = $UserWorksheet.Cells.Item($intRow, 7).Value()
 $intRow++
 Get-aduser -f {name -like $name} | set-aduser -title $Titre  -Department $Service -city $Emplacement -Mobilephone $cellullaire -OfficePhone $telephone -office  $Emplacement -Organization "Pierre Fabre Dermo-Cosmétique" 
 
} While ($UserWorksheet.Cells.Item($intRow,1).Value() -ne $null)
 
 
 $objExcel.Quit()
