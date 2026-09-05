<#
.SYNOPSIS
    Gets Markdown Start Pattern
.DESCRIPTION
    Gets a Regular Expression that matches the start of Markdown content.

    Anything before this point may be considered JavaScript.
.NOTES
    The start pattern will look for the first of any of these tags:

    * Heading 
    * Tag
    * Fragment
    * Code Block
#>
param()

$lookingFor = @(
    '\#{1,6}\s'
    '\<\w+'
    '\<\>'
    '`{3}'
    '~{3}'
)

[Regex]::new(
    "(?=(?>$($lookingFor -join '|')))",
    'IgnoreCase'
)