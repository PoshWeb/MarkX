<#
.SYNOPSIS
    Saves Markdown
.DESCRIPTION
    Saves Markdown content into a new file.
#>
param(
# The path used to save the content
[string]
$Path,

# Any options used to determine how the content is saved.
[Alias('Options')]
[Collections.IDictionary]
$Option = [Ordered]@{}
)

# Determine the save path
$savePath =
    if ($path) {
        # If a path was passed, it can either be a real path
        # or, if a date is present
        if ($this.Date) {
            # `ymd`, `y-m-d` or `year-month-day` a year month day post                        
            if ($path -in 'ymd', 'y-m-d', 'Year-Month-Day') {
                "$($this.Date.ToString('yyyy-MM-dd'))$(
                    if ($this.Title) {
                        "-$($this.Title -replace '[\p{P}\p{S}]', '-')"
                    }
                ).md"
            } elseif ($path -in 'y/m/d', 'Year/Month/Day') {
                "$($this.Date.ToString('yyyy/MM/dd'))$(
                    if ($this.Title) {
                        "/$($this.Title -replace '[\p{P}\p{S}]', '-')"
                    }
                ).md"                
            }
        } else {
            # Otherwise, use the specified path.
            $path
        }
    }
    # Otherwise, if the post had a title
    elseif ($this.Title) {
        # and a date
        if ($this.Date) {
            "$(
                # include the date in yyyy/MM/dd format
                $this.Date.ToString('yyyy/MM/dd')
            )/$(
                # Then include the title.
                $this.Title -replace '[\p{P}\p{S}]', '-'
            ).md"
        } else {
            # Otherwise, just include the title.
            "$($this.Title -replace '[\p{P}\p{S}]', '-').md"
        }        
    }
    # If the post only had a date,
    elseif ($this.Date) {
        # Stringify the time, including seconds.
        "$($this.Date.ToString('s') -replace ':','_').md"
    }
    else {
        # If no path information was provided,
        # no date or title was found on the post,
        # then we will autosave to the current time,
        # (including milliseconds)
        "$([DateTime]::Now.ToString('o') -replace ':','_').md"
    }


# Prepare our parameters for New-Item
$saveSplat = [Ordered]@{
    Path = $savePath
    Force = $true
    ItemType = 'File'
}

# By default we will save the `.Content`.
$saveSplat.Value = "$($this.Content)"

# If `.OnlyMarkdown` or `.MarkdownOnly` were in options
if ($Option.OnlyMarkdown -or $Option.MarkdownOnly) {
    # then we will only save the markdown portion
    $saveSplat.Value = "$($this.Markdown)"
}

# If the path is a specific extension,
# we may want to save it a specific way. 
switch -regex ($savePath) {
    # If it is json
    '\.json$' {
        # we will save it as [MarkPub](https://markpub.at).
        $saveSplat.Value = "$($this.JSON)"
    }
    # If it is `.html`
    '\.html?$' {
        # we will always save the `html` property
        $saveSplat.Value = "$(
            $this.Html
        )"
    }
    # If it is `.svg`
    # create an element with a `<foreignObject>`  inside of it.    
    '\.svg$' {
        $svg = $this.SVG
        $saveSplat.Value = @(
            if ($svg.OuterXml){
                $svg.OuterXml
            } else {
                $svg
            }
        ) -join [Environment]::NewLine
    }
}

if ($Option.WhatIf -or 
    $option.PassThru -or 
    $WhatIfPreference) {
    return $saveSplat
}

New-Item @saveSplat