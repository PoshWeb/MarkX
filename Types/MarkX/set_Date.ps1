<#
.SYNOPSIS
    Sets the Markdown date
.DESCRIPTION
    Sets the Markdown date in a Yaml Header
#>
param(
[DateTime]
$Date = [DateTime]::Now
)

$header = $this.Header
if (-not $header) { 
    $this.YamlHeader = [Ordered]@{
        date = $Date
    }
    return
}
$header.date = $Date
$this.YamlHeader = $header