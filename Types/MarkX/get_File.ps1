<#
.SYNOPSIS
    Get MarkX files
.DESCRIPTION
    Gets the MarkX files.
    
    If the MarkX has a `.Path`, it will get files beneath that path.
    If the MarkX has a `.Site.Root`, it will get files beneath each root.
.NOTES
    Will explicitly skip any files in `node-modules`
#>
param()

$noise = '[\\/](?>node_modules)'

$enumOptions = [IO.EnumerationOptions]::new()
$enumOptions.RecurseSubdirectories = $true
$thisPath = $this.Path
if ($thisPath) {
    if ([IO.File]::Exists($thisPath)) {
        return ($thisPath -as [IO.FileInfo])
    } elseif ([IO.Directory]::Exists($thisPath)) {
        return 
            @(($thisPath -as [IO.DirectoryInfo]).EnumerateFiles('*',$enumOptions)) -notmatch $noise
    }
} else {
    if ($this.Site.root) {        
        foreach ($rootDirectory in $this.Site.Root) {
            $rootDirectory = $rootDirectory -as [IO.DirectoryInfo]
            if ($rootDirectory.EnumerateFiles) {
                @($rootDirectory.EnumerateFiles('*',$enumOptions)) -notmatch $noise
            }
        }
    }
}