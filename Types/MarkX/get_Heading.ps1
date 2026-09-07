<#
.SYNOPSIS
    Gets Markdown headings
.DESCRIPTION
    Gets any heading elements in the markdown
#>
$this.XML | 
    Select-Xml -XPath //* |
    Where-Object {
        $_.Node.LocalName -match 'h[1-6]'
    } |
    Select-Object -ExpandProperty Node