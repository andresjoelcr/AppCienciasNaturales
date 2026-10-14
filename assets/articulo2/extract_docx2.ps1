Add-Type -AssemblyName System.IO.Compression.FileSystem
$docxPath = "C:\Users\LENOVO\Documents\mi_app\assets\articulo2\articulo_temp.docx"
$outputPath = "C:\Users\LENOVO\Documents\mi_app\assets\articulo2\articulo_content.txt"

$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$content = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()

# Parse XML and extract text with better formatting
[xml]$xml = $content
$ns = @{w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}

$paragraphs = Select-Xml -Xml $xml -XPath "//w:p" -Namespace $ns

$result = ""
foreach ($p in $paragraphs) {
    $texts = $p.Node.SelectNodes(".//w:t", $xml.CreateNavigator().NameTable)
    $paraText = ""
    foreach ($t in $p.Node.ChildNodes) {
        if ($t.LocalName -eq "r") {
            foreach ($child in $t.ChildNodes) {
                if ($child.LocalName -eq "t") {
                    $paraText += $child.InnerText
                }
            }
        }
    }
    if ($paraText.Trim() -ne "") {
        $result += $paraText + "`r`n`r`n"
    }
}

$result | Out-File -FilePath $outputPath -Encoding UTF8
Write-Output "Content extracted to: $outputPath"
