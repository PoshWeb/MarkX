<#
.SYNOPSIS
    Gets Markdown as HTML
.DESCRIPTION
    Gets Markdown as HTML.

    If the Markdown has no JavaScript, will simply convert the markdown into HTML.

    If the Markdown has JavaScript, will generate a fullscreen page.

    * Any `ImportMap` in the header will be declared as a `<script type='importmap'>`
    * The `Title` in the front matter will become a `<title>`
    * Any applicable metadata will be propagated into `<meta>` tags
    * The markdown will be rendered inline
    * The JavaScript will become a JavaScript module `<script type='module'>`
.NOTES
    If the markdown cannot be coerced into XML, this should use ConvertFrom-Markdown.
#>

$jsHeader = $this.JavaScript
$header = $this.Header

# If there is not a javascript header, 

if (-not $jsHeader) {
    # but the front matter contains javascript
    if ($header.javascript) {
        # that will do.
        $jsHeader = $header.javascript
    } elseif (
        # otherwise, if the header is a string and contains javascript keywords
        $header -is [string] -and $header -match $this.JavaScriptKeywordPattern
    ) {
        # treat this as the javascript header.
        $jsHeader = $header
    }
}
if ($jsHeader) {    
    return @(
        # If the header had a title
        if ($header.title) {
            # propagate it into `<title>`
            "<title>$($header.title)</title>"
        }

        # If the header had a date
        if ($this.date) {
            # propagate it into `article:published_time`
            "<meta property='article:published_time' content='$($this.date.ToString('o'))' />"
        }

        # If the header had any opengraph keys
        foreach ($openGraph in @($header.Keys) -match ':') {
            # propagate them into `<meta>` elements.
            "<meta property='$($openGraph)' content='$(
                [Web.HttpUtility]::HtmlAttributeEncode(
                    "$($header.$openGraph)"
                ))' />"
        }

        # Occupy the full screen 
        "<style>body { max-width: 100vw; height: 100vh; margin: 0}</style>"

        # If the header provided an import map
        if ($header.importmap) {
            # propagate it into `<script type='importmap'>`
            "<script type='importmap'>$(
                $header.importmap | ConvertTo-Json -Depth 3
            )</script>"
        }        
        

        $after = $null
        
        $null, $after = $this.Markdown -split $this.StartPattern, 2
        if ($after) {
            ($after | ConvertFrom-Markdown).Html
        }

        "<script type='module'>"
            $jsHeader
        "</script>"
    ) -join [Environment]::NewLine
}

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