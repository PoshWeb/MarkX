<#
.SYNOPSIS
    Gets JavaScript Keyword Pattern
.DESCRIPTION
    Gets a keyword pattern that denotes JavaScript

    Will match any line beginning with optional whitespace followed by one of:

    * `import`
    * `export`
    * `const`
    * `let`
    * `document`
    * `window`
#>
[Regex]::new('^\s{0,}(?>import|export|const|let|document|window)', 'Multiline,IgnoreCase')
