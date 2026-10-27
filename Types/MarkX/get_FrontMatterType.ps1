<#
.SYNOPSIS
    Gets Front Matter Type
.DESCRIPTION
    Gets the type of Front Matter in a file.
#>

switch -regex ($this.FrontMatter) {
    '^[\s\r\n]{0,}(?>\[\w+|.+?=)' {
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

