<#
.SYNOPSIS
    Gets Markdown Files
.DESCRIPTION
    Gets Markdown files.
    
    If the MarkX has a `.site.root`,
    will get all markdown files from that root.

    If the MarkX has a path, will return `$this`
#>
param()

# Create an extension for all markdown files.
$MarkdownFilePattern = "(?>\.$(
    @($this.MarkdownExtension -replace '\.') -join '|'
))"

# If this is already a markdown file, return as-is
if ($this.Path -match $MarkdownFilePattern) { return $this }

# If this does not have a cache, create one now
if (-not $this.'#Cache') {
    $this | Add-Member NoteProperty '#Cache' ([Ordered]@{}) -Force
}

# Why cache?  Because we want to avoid re-parsing files
# This can be especially useful for large sites.
$notCached = [Collections.Queue]::new()

# Go over all files in the site
foreach ($file in $this.File) {
    # and skip any that are not markdown files.
    if ($file.Name -notmatch $MarkdownFilePattern) { continue }

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
