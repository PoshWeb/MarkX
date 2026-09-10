<#
.SYNOPSIS
    Gets Markdown Links
.DESCRIPTION
    Gets anchor links from within Markdown content.
.NOTES
    This will return the links nodes after the Markdown is converted to XML.
    
    If XML conversion fails, this will not return any values.

    To find hyperlinks within Markdown, use `.FindHyperlink()`
#>
foreach ($aNode in $this.XML | Select-Xml //a) {
    if ($aNode.Node.href) {
        $aNode.Node
    }
}