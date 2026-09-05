<#
.SYNOPSIS
    Sets the Markdown tags
.DESCRIPTION
    Sets the Markdown tags, according to it's YamlHeader `tags` field.
#>
param(
[string[]]
$Tags
)

$header = $this.Header
if (-not $header) { 
    $this.YamlHeader = [Ordered]@{
        tags = $Tags
    }
    return
}
$header.tags = $Tags
$this.YamlHeader = $header

return $this.Header.tags
