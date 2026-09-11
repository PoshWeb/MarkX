<#
.SYNOPSIS
    Gets Markdown Front Matter
.DESCRIPTION
    Gets any cached Markdown front matter as a string.

    To get front matter an an object, please use `.Header`
.LINK
    MarkX.get_Header
#>
[OutputType([string])]
param()
return $this.'#FrontMatter'