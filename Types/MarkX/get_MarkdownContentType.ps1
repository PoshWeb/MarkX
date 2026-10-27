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
    # Servers are likely to return this as `application/octet-stream`
    # but it is a text based content type.
    '.astro' = 'text/astro' 
}