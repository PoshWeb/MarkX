<#
.SYNOPSIS
    Gets Markdown as a Data Url
.DESCRIPTION
    Gets the Markdown as a Data Url.
    
    This can be used as an image source `<img src>`.
#>
$svg = $this.Svg
"data:image/svg+xml;base64,$(
    [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$(
        if ($svg.OuterXml) {
            $svg.OuterXml
        } else {
            $svg
        })"))
)"
