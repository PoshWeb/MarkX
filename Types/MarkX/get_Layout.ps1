<#
.SYNOPSIS
    Gets Markdown Layout
.DESCRIPTION
    Gets the layout.
    
    If a layout script has been set, this will return that script

    Otherwise, this will return the layout defined in the front matter.
#>
param()
if ($this.'#layout' -is [scriptblock]) { return $this.'#layout' }
else { return $this.Header.layout }