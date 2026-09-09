<#
.SYNOPSIS
    Gets the Site Type
.DESCRIPTION
    Gets the Site or Page Type.

    Will scan any files in the site or page for what technology is being used.

    Multiple site types will most likely be detected.
#>
param()

# This list will expand with time

@(switch -regex ($this.File.Name) {
    '\.css(?>\.|$)' { 'css'}
    '\.c(?>\.|$)' { 'c' }
    '\.cpp(?>\.|$)' { 'c++' }
    '\.rs(?>\.|$)' { 'rust' }
    '\.go(?>\.|$)' { 'go' }
    '\.html(?>\.|$)' { 'html '}
    '\.js(?>\.|$)' { 'javascript' }
    '\.json(?>\.|$)' { 'json' }
    '\.jsx(?>\.|$)' { 'jsx'}
    '\.md(?>\.|$)' { 'markdown'}
    '\.mdx(?>\.|$)' { 'mdx'}
    '\.ps[dm]?1$' { 'PowerShell' }
    '\.pl(?>\.|$)' { 'Perl'}
    '\.php(?>\.|$)' { 'PHP'}
    '\.ts(?>\.|$)' { 'typescript' }    
    '^hugo\.' { 'hugo' }
    'astro' { 'astro'}
    'eleventy' { 'eleventy' }
    'jekyll' { 'jekyll' }
    'package\.json' { 'javascript' }
    'tsconfig' { 'typescript'}
}) | Select-Object -Unique
