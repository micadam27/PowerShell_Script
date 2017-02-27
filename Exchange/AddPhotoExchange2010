#picture's name must be the AD username of the suer

$fileDirectory = 'C:\pics'
cd 'c:\pics'
foreach($file in Get-ChildItem $fileDirectory)
{
$name = [io.path]::GetFileNameWithoutExtension($file)
Import-RecipientDataProperty -Identity $name -Picture -FileData ([Byte[]]$(Get-Content -Path $file -Encoding Byte -ReadCount 0))
Write-Host $name
}
