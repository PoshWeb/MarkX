<#
.SYNOPSIS
    Get the Liquid Pattern
.DESCRIPTION
    Gets the regular expression pattern used to match Liquid tags.
#>
param()
$liquidPattern = @(
    '(?>'
        '\{\%\s{0,}'
        '(?<tag>[^\%]+)'
        '\s{0,}\%}'
        
        '|'

        '(?<noescape>\{{3})'
        '(?<expression>[^\}]+)'
        '\}{3}'

        '|'

        '\{{2}'
        '(?<expression>[^\}]+)'
        '\}{2}'
    ')'    
) -join ''

return [Regex]::new($liquidPattern)
