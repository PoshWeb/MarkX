<#
.SYNOPSIS
    Gets Front Matter Type
.DESCRIPTION
    Gets the type of Front Matter in a file.
#>

switch -regex ($this.FrontMatter) {
    '(?m)^\[[\w\d_\.]+\]' {
        return 'toml'
    }
    $this.JavaScriptKeywordPattern {
        return "javascript"
    }
    '(?m)^[\{\[]' {
        return 'json'
    }
    '(?m)^[\w-]+:' {
        return 'yaml'
    }
}

