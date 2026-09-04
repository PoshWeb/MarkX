<#
.SYNOPSIS
    Gets Markdown JavaScript
.DESCRIPTION
    Gets the JavaScript header of a Markdown or mdx file.

    We will consider anything before the first header element to be a javascript header.
#>
$before, $after = $this.Markdown -split '(?=\#{1,6}\s)', 2
return $before