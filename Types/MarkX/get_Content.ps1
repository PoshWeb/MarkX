<#
.SYNOPSIS
    Gets Markdown Content
.DESCRIPTION
    Gets the combined content of the markdown.
    
    This contains both the Markdown and the YAML Header.
#>
@(if ($this.FrontMatter) {
    "---"
    $this.FrontMatter
    "---"
    $this.Markdown
} else {
    $this.Markdown
}) -join [Environment]::NewLine