<#
.SYNOPSIS
    Sets a MarkX site
.DESCRIPTION
    Sets site information for a collection of documents.
.EXAMPLE
#>
param(
<#
This parameter is untyped.  It may be an array, a string, or a path.

If a string is passed, will set a site root or add an additional site root.

If a dictionary is passed, will set a site dictionary.

If a psobject is passed, will set every property on the object.
#>
$Site
)



$addSite = @{inputObject=$this;MemberType='NoteProperty';Name='#Site';Force=$true}
foreach ($siteInfo in $site) {
    if ($siteInfo -is [Management.Automation.PathInfo]) {
        $siteInfo = "$siteInfo"
    }
    if ($siteInfo -is [string]) {
        if ([IO.Directory]::Exists($siteInfo)) {
            if (-not $this.'#Site') {                
                Add-Member @addSite -Value ([Ordered]@{
                    root = $siteInfo
                })
            } else {
                # If the site is a new root, make it a list of unique roots.                
                $this.'#Site'.root = @(
                    @($this.'#Site'.root) + $siteInfo | Select-Object -Unique
                )
            }           
        }
    }
    elseif ($siteInfo -is [Collections.IDictionary]) {
        if (-not $this.'#Site') {
            Add-Member @addSite -Value $siteInfo
        } else {
            foreach ($key in $siteInfo.Keys) {
                $this.'#Site'[$key] = $siteInfo[$key]
            }            
        }
    }
    else {
        if (-not $this.'#Site') {
            Add-Member @addSite -Value ([Ordered]@{})            
        }

        foreach ($prop in $siteInfo.psobject.properties) {
            $this.'#Site'[$prop.Name] = $siteInfo.($prop.Name)
        }        
    }
}


return $this.'#Site'