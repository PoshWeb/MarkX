<#
.SYNOPSIS
    Sets Markdown Json Header
.DESCRIPTION
    Sets the Markdown Front Matter as a JSON header.

    If the value is a `[string]`, will directly set front matter.
    
    If the value is not a `[string]`, it will be converted to JSON.
#>
param($header)

if ($header -is [string]) {
    $this | Add-Member NoteProperty '#FrontMatter' $header -Force
    return
}

$jsonHeader = $header | ConvertTo-Json -Depth 100

$this | Add-Member NoteProperty '#JsonHeader' $jsonHeader -Force
$this | Add-Member NoteProperty '#FrontMatter' $jsonHeader -Force

return