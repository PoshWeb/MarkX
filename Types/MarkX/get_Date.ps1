<#
.SYNOPSIS
    Gets the Markdown date
.DESCRIPTION
    Gets the Markdown date, according to it's YamlHeader `date` field.
#>
param()

$header = $this.Header


if ($header.date -is [DateTime]) {
    return $header.date
} elseif ($header.date -as [DateTime]) {
    return $header.date -as [DateTime]
} elseif ($this.Path -match '(?>^|[\\/])\d{4}[-/]\d{2}[-/]\d{2}') {
    $match = "$($matches.0)"
    $date = $matches.0 -replace '^[\\/]' -replace '/', '-' -as [DateTime]
        
    if ($date) {
        $this.Date = $date
        return $date        
    }    
}