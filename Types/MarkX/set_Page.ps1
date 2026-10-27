<#
.SYNOPSIS
    Sets Page data
.DESCRIPTION
    Sets Markdown Page data.
    
    Merges data with existing data and sets properties on the object.
.NOTES
    This data is somewhat independent of the front matter.

    It will not be saved, and may be interpreted differently by different engines.

    When it is initialized, various front matter may be replicated into page data.

    When set, settable properties on this object will be changed, 
    and may propagate into page data.
#>
param([Collections.IDictionary]$Page)

$oldPage = $this.Page

foreach ($key in $page.Keys) {
    # If this was something we could set
    if ($key -and $this.psobject.Properties[$key].IsSettable) {
        # set it.
        $this.$key = $page[$key]
        # This should propagate any data, but, if it did not
        if (-not $oldPage[$key]) {
            # set it in the page.
            $oldPage[$key] = $page[$key]
        }
    } else {
        # Otherwise, simply set the property on our page.
        $oldPage[$key] = $page[$key]
    }
}
