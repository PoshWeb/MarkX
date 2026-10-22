<#
.SYNOPSIS
    Gets a Markdown Path
.DESCRIPTION
    Gets the path associated with a Markdown file.
#>
if ($this.'#Path') {
    return $this.'#Path'
}

if ($this -is [Management.Automation.ExternalScriptInfo]) {
    return $this.Source
}