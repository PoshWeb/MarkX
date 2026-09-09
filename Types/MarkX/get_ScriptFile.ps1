<#
.SYNOPSIS
    Gets MarkX Script Files
.DESCRIPTION
    Gets PowerShell Script Files in a MarkX site
#>

if ($this -is [Management.Automation.ExternalScriptInfo]) {
    return $this
}

# If this does not have a cache, create one now
if (-not $this.'#Cache') {
    $this | Add-Member NoteProperty '#Cache' ([Ordered]@{}) -Force
}

# Why cache?  Because we want to avoid re-parsing files
# This can be especially useful for large sites.
$notCached = [Collections.Queue]::new()

# Go over all files in the site
foreach ($file in $this.File -match '\.ps1$') {
    # and skip any that are not markdown files.
    # if ($file.Name -notmatch $MarkdownFilePattern) { continue }

    # If they have not yet been cached,
    if (-not $this.'#Cache'[$file.FullName]) {
        # cache them.
        $notCached.Enqueue($file.FullName)
    } else {
        $this.'#Cache'[$file.FullName]
    }
}

foreach ($markx in $notCached.ToArray() | markx) {
    if ($markx.Path) {
        if ($this.'#site') {
            $markx.Site = $this.'#site'
        }
        $this.'#Cache'[$markX.Path] = $markx
        $this.'#Cache'[$markX.Path]
    } else {
        $null = $null
    }
}
