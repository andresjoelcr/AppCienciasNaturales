Add-Type -AssemblyName System.IO.Compression.FileSystem
$docxPath = "C:\Users\LENOVO\Documents\mi_app\assets\articulo2\articulo_temp.docx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$content = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
[xml]$xml = $content
$text = $xml.document.body.InnerText
Write-Output $text
