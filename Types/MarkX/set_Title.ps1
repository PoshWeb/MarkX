<#
.SYNOPSIS
    Sets the Markdown title
.DESCRIPTION
    Sets the Markdown title in a Yaml Header
#>
param(
[string]
$Title
)

$header = $this.Header
if (-not $header) { 
    $this.YamlHeader = [Ordered]@{
        title = $Title
    }
    return
}
$header.title = $Title
$this.YamlHeader = $header

# If page data has been initialized,
if ($this.'#Page' -is [Collections.IDictionary]) {
    # update the title in the page.
    $this.'#Page'.title = $Title
}