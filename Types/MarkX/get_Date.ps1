<#
.SYNOPSIS
    Gets the Markdown date
.DESCRIPTION
    Gets the Markdown date, according to it's YamlHeader `date` field.
#>
param()

$header = $this.Header
if (-not $header.date) { return }

if ($header.date -is [DateTime]) {
    return $header.date
} elseif ($header.date -as [DateTime]) {
    return $header.date -as [DateTime]
}