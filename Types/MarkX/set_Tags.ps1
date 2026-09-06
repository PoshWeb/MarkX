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

# If page data has been accessed,
if ($this.'#Page' -is [Collections.IDictionary]) {
    # update the tags
    $this.'#Page'.tags = $Tags
}


