<#
.SYNOPSIS
    Gets the Markdown tags
.DESCRIPTION
    Gets the Markdown tags, according to it's YamlHeader `tags` field.
#>
param()

return $this.Header.tags
