<#
.SYNOPSIS
    Gets Markdown Table of Contents
.DESCRIPTION
    Gets a Markdown Table of Contents for the current Markdown.

    This will create a series of bullet points linking to each heading level.
.EXAMPLE
    $m = markx @(
        "# h1 "
        "## h2"
        "## h2-2" 
        "### h3" 
        "##### h5" 
        "##### h5-2" 
        "###### h6" 
        "## h2-2"
        "# h1-2"
        "### h3-3"
        "#### h4"
        "#### h4-2"
        "## h2-3"
    )
    $m.TableOfContents
#>
param()


$currentDepth = 0
$currentHeadingLevel = 1
$headingDepths = [Ordered]@{"1"=0}
$headings = @($this.Heading)
for ($headingIndex = 0; $headingIndex -lt $headings.Length; $headingIndex++) {
    $heading = $headings[$headingIndex]
    $headingLevel = ($heading.LocalName -replace 'h') -as [int]
    if ($headingLevel -gt $currentHeadingLevel) {
        $currentDepth += 2
        $currentHeadingLevel = $headingLevel
        $headingDepths["$headingLevel"] = $currentDepth
    }
    elseif ($headingLevel -lt $currentHeadingLevel) {
        if ($null -ne $headingDepths["$headingLevel"]) {
            $currentDepth = $headingDepths["$headingLevel"]
        } else {
            $currentDepth -= 2
        }
        $currentHeadingLevel = $headingLevel        
    }

    if (-not $currentDepth) {
        $headingDepths = @{"1"=0}
    }
    
    "$(' ' * $currentDepth)* [$($heading.InnerText)](#$($heading.id))"

}
foreach ($heading in $this.Heading) {
    
}
