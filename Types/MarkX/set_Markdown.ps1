<#
.SYNOPSIS
    Sets Markdown
.DESCRIPTION
    Sets the Markdown on an object.
.NOTES
    This will change the `.Input` property, which will then `.Sync()` the markdown.
#>
param(
# Any new or updated markdown content.
[PSObject[]]$Markdown
)

$this.Input = $Markdown
