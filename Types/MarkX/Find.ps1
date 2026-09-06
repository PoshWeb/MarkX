<#
.SYNOPSIS
    Markdown Find
.DESCRIPTION
    Finds patterns within Markdown content.

    This will search the combined front matter and markdown using a regular expression.
.NOTES
    If the pattern provided is not a regular expression, 
    and can be cast to one,
    it will be treated as a regular expression with the options:

    * IgnoreCase
    * IgnorePatternwhitespace

    If the pattern cannot be cast to a regular expression,
    it will be stringified and escaped.
#>
param(
# The pattern
$Pattern
)

# If the pattern is a pattern
if ($Pattern -is [Regex]) {
    # just match
    return $Pattern.Matches("$($this.Content)")
} elseif (    
    # If it can be cast,
    $Pattern -is [string] -and $pattern -as [regex]
) {
    # create it and match
    return [Regex]::new($Pattern,'IgnoreCase,IgnorePatternWhitespace').Matches(
        "$($this.Content)"
    )    
} elseif (
    # If it can be stringified
    $pattern.ToString
) {
    # Stringify it.
    [Regex]::new([Regex]::Escape($pattern.ToString()), 'IgnoreCase').Matches(
            "$($this.Content)"
    )
}