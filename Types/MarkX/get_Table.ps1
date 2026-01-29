<#
.SYNOPSIS
    Gets any tables
.DESCRIPTION
    Gets any tables present in the markdown
#>
$this.XML | 
    Select-Xml -XPath '//table' | 
    Select-Object -ExpandProperty Node