<#
.SYNOPSIS
    Gets Front Matter Type
.DESCRIPTION
    Gets the type of Front Matter in a file.
#>

switch -regex ($this.FrontMatter) {
    '(?m)^.+?=' {
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

