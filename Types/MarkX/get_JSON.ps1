<#
.SYNOPSIS
    Gets Markdown JSON
.DESCRIPTION
    Gets Markdown as JSON.
    
    Uses the [Markpub](https://markpub.at) format.
#>
param()
$this.markpub | ConvertTo-Json -Depth 100