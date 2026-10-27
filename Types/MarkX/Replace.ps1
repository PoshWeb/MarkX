<#
.SYNOPSIS
    Markdown Replace
.DESCRIPTION
    Replace patterns within Markdown content.

    This will search the combined front matter and markdown using a regular expression.
#>
param(
<#
The pattern.

If the pattern provided is not a regular expression, 
and can be cast to one,
will be treated as a regular expression with the options:

* IgnoreCase
* IgnorePatternwhitespace

If the pattern cannot be cast to a regular expression,
it will be stringified and escaped.
#>
$Pattern,

# The replacement.
# This can be a `[ScriptBlock]` or a 
# `[Text.RegularExpressions.MatchEvaluator]`
$Replacement
)

$Pattern = 
    # If the pattern is a pattern
    if ($Pattern -is [Regex]) {
        # just match
        $Pattern.Matches("$($this.Content)")
    } elseif (    
        # If it can be cast,
        $Pattern -is [string] -and $pattern -as [regex]
    ) {
        # create it and match
        [Regex]::new($Pattern,'IgnoreCase,IgnorePatternWhitespace', '00:00:01')
    } elseif (
        # If it can be stringified
        $pattern.ToString
    ) {
        # Stringify it.
        [Regex]::new([Regex]::Escape($pattern.ToString()))
    }


# If the replacement was a lambda
$replaced = if (    
    $Replacement -is [ScriptBlock] -or 
    $Replacement -is [Text.RegularExpressions.MatchEvaluator]
) {
    # call it directly
    $Pattern.Replace("$($this.Content)",$Replacement)
} else {
    # Otherwise, stringify the replacement
    $Pattern.Replace("$($this.Content)", "$Replacement")
}

$this.Content = $replaced

# Return ourself so we can chain operations.
return $this