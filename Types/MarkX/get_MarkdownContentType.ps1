<#
.SYNOPSIS
    Gets Markdown content types
.DESCRIPTION
    Gets the appropriate Content Type for markdown files, given a number of extensions.
#>
[Ordered]@{
    '.md' = 'text/markdown'
    '.mdx' = 'text/mdx'
    '.markdown' = 'text/markdown'
}