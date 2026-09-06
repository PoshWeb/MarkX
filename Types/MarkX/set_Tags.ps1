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

# Select-Object -Unique to ensure we don't tag twice.
$Tags = $Tags | Select-Object -Unique

$header = $this.Header
if (-not $header) { 
    $this.YamlHeader = [Ordered]@{
        tags = $Tags
    }
    return
}
$header.tags = $Tags
$this.YamlHeader = $header

# If page data has been initialized,
if ($this.'#Page' -is [Collections.IDictionary]) {
    # update the tags in the page.
    $this.'#Page'.tags = $Tags
}


