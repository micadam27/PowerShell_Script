$logfile = "C:\Utils\Scripts\Logs\logpostbackup-" + "$(get-date -f yyyy-MM-dd)" + ".txt"
Robocopy S:\Backup\VeeamRepository D:\Backups\CopyToUSB\ /NOCOPY /PURGE
robocopy S:\Backup\VeeamRepository D:\Backups\CopyToUSB\  /e /purge /log:$logfile /NFL /NDL


$Body = Get-Content -Path $logfile -raw
Send-MailMessage -To "info@departement-ti.com" -From "sauvegardeConnectAll@bellnet.ca" -Subject "Sommaire copie USB" -SmtpServer "smtp.bellnet.ca" -Body $Body

