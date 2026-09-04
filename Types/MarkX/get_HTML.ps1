<#
.SYNOPSIS
    Gets Markdown as HTML
.DESCRIPTION
    Gets Markdown as HTML.
.NOTES
    If the markdown cannot be coerced into XML, this should use ConvertFrom-Markdown.
#>
if (-not $this.XML.XHTML) {
    if ($this.'#HTML') {
        return "$($this.'#HTML')" + [Environment]::NewLine
    }
    else {
        return $this.Markdown |
            ConvertFrom-Markdown |
            Select-Object -ExpandProperty Html
    }    
}
return ("$($this.XML.XHTML.InnerXML)" + [Environment]::NewLine)