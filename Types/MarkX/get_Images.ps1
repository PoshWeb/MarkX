<#
.SYNOPSIS
    Gets Markdown Images
.DESCRIPTION
    Gets `<img>` tags found within Markdown after it has been converted to XML
.NOTES
    If the Markdown could not be converted to XML, this will return nothing.
#>
foreach ($aNode in $this.XML | Select-Xml //img) {
    if ($aNode.Node.src) {
        $aNode.Node
    }
}