<#
.SYNOPSIS
    Sets Markdown Header
.DESCRIPTION
    Sets the Markdown Front Matter from a header object.

    This will overwrite any existing front matter.
#>
param($header)

$this.FrontMatter = $header