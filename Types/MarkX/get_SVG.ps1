<#
.SYNOPSIS
    Gets Markdown SVG
.DESCRIPTION
    Gets the Markdown as a SVG image
.NOTES
    Since we can embed most HTML into SVG using a `<foreignObject>` element.

    All we need to do to Convert Markdown into SVG is convert it to html 
    and put it within a `<foreignObject>`.
#>
[OutputType([xml],[string], "image/svg+xml")]
param()
$svg = @(
    "<svg xmlns='http://www.w3.org/2000/svg'>"
    "<foreignObject width='100%' height='100%'>"
    "<xhtml xmlns='http://www.w3.org/1999/xhtml'>"
    $this.HTML
    "</xhtml>"
    "</foreignObject>"
    "</svg>"
) -join [Environment]::NewLine

# If this could be cast to xml
if ($svg -as [xml]) {
    # return as xml
    $svg -as [xml]
} else {
    # otherwise, return as text.
    $svg
}