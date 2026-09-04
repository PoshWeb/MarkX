<#
.SYNOPSIS
    Gets the Markdown title
.DESCRIPTION
    Gets the Markdown title.

    If a title is set in the header, this will be the title.
    
    Otherwise, will return the first h1 element 
#>
param()

$header = $this.Header
if (-not $header.title) { 
    if ($this.XML) {
        return $this.XML | 
            Select-Xml //h1 |
                Select-Object -First 1 |  
                    ForEach-Object {
                        $_.Node.InnerText
                    }              
    } else {
        return
    }    
}

return $header.title