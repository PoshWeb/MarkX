<#
.SYNOPSIS
    README.md.ps1
.DESCRIPTION
    README.md.ps1 makes README.md

    This is a simple and helpful scripting convention for writing READMEs.

    `./README.md.ps1 > ./README.md`

    Feel free to copy and paste this code.
    
    Please document your parameters, and add NOTES.
.NOTES        
    This README.md.ps1 is used to demonstrate [MarkX](https://github.com/PoshWeb/MarkX).
.EXAMPLE
    ./README.md.ps1 > ./README.md
.EXAMPLE
    Get-Help ./README.md.ps1
.LINK
    https://github.com/PoshWeb/MarkX
#>
#requires -Module MarkX
param()
@"

# Hello World

## Greetings from MarkX!

"@ | MarkX

@"

[![MarkX PowerShell Gallery](https://img.shields.io/powershellgallery/dt/MarkX)](https://www.powershellgallery.com/packages/MarkX/)

"@ | MarkX

@'

### What Is MarkX?

MarkX is a useful little tool built around a useful little trick.

Markdown is text that turns into nicely balanced and escaped HTML.

We can put that HTML into any `<tag>` and treat it as `<xml>`.

This lets us query and manipulate markdown, giving us the best of both worlds.

It's easy to write text, and an easy to read document tree.

'@ | MarkX



@'

### Installing and Importing

You can install MarkX from the PowerShell Gallery, using `Install-Module`:

~~~PowerShell
Install-Module MarkX
~~~

Once install, you can import it with `Import-Module`

~~~PowerShell
Import-Module MarkX
~~~

'@ | markX


@'

### Getting Started

Let's start simple, by making some markdown:


~~~PowerShell
"# Hello World" | MarkX
~~~

When we run this, we should see two properties:  Markdown and XML.

Whenever we change the Markdown, everything else is updated.
'@ | MarkX



$gettingLinks = {
$markXLinks =
"* [My Website](https://MrPowerShell.com/)",
"* [GitHub](https://github.com/StartAutomating)",
"* [BlueSky](https://bsky.app/profile/mrpowershell.com)" | 
    markx

@($markXLinks.Links.Href |        
    ForEach-Object { 
        "* $($_)"
    }) -join [Environment]::NewLine
}

@"


### Getting Links

Let's see how this can be useful, by getting some links.

~~~PowerShell
$gettingLinks
~~~

When we run this, we get:

$(& $gettingLinks)

"@ | MarkX


$gettingImages = {

$markXImages =
"* ![Mind Blown Stranger Things](https://media1.tenor.com/m/rReKAT-J3nsAAAAd/mind-blown-boom.gif)",
    "* ![Mind Blown Big Mouth](https://media1.tenor.com/m/rD98-O3i1xYAAAAC/what-mind-blown.gif)"
     | markx
@(
$markXImages

$markXImages.Images |        
    ForEach-Object { 
        "* [$($_.alt)]($($_.src))"
    }
) -join [Environment]::NewLine

}


@"

### Getting Images

Let's see how this can be fun, by getting some images.

~~~PowerShell
$gettingImages
~~~

When we run this, we get:

$(& $gettingImages)

"@ | MarkX


$makingTables = {

$timesTable = @(
    "#### TimesTable"
    foreach ($rowN in 1..9) {
        $row = [Ordered]@{}
        foreach ($colN in 1..9) {
            $row["$colN"] = $colN * $rowN
        }
        $row
    }
) | MarkX

$timesTable

}



@"

### Making Tables 

Let's make some tables

~~~PowerShell
$makingTables
~~~

When we run this, we get:

$(& $makingTables)

"@ | MarkX


$markx = @'

### Tables Become Data

Ok, this gets really cool.

_Tables become data_!

Because we can easily extract out the `<table>` elements inside of markdown, we can turn it into data.

And because the .NET framework includes a nifty in-memory database, we can turn this into something we can query.

#### The Nearest Heading Is The Table Name
> A blockquote is the description

|a|b|c|
|-|-|-|
|1|2|3|

'@ | MarkX



$markx

$GetMarkdownTableData = {

$markxTables = @'
#### abc
|a|b|c|
|-|-|-|
|1|2|3|
|4|5|6|
|7|8|9|

#### def

|d|e|f|
|-|-|-|
|1|2|3|
|2|4|6|
|3|6|9|
|4|8|12|

'@ | MarkX 
$markxTables
$markxTables.DB.Tables["abc"].Compute('sum(a)','') # | Should -Be 12    
$markxTables.DB.Tables["def"].Compute('sum(d)','') # | Should -Be 10
}


@"
~~~PowerShell
$GetMarkdownTableData
~~~

When we run this example, we get:

$(& $GetMarkdownTableData)

"@ | MarkX


$lexiconMarkdown = @'


### Markdown Lexicons

Since we can extra tables and data Markdown, we can also get any data of a particular known shape.

The first special shape MarkX supports is an [at protocol lexicon](https://atproto.com/guides/lexicon)

MarkX current supports lexicon type definitions.  It will support query and procedure definitions in the future.

A type definition consists of a namespace identifier, a description, and a series of properties.

#### com.example.happy.birthday
> An example lexicon to record birthday messages

|Property|Type|Description|
|-|-|-|
|`$type`      | `[string]`   | The type of the object.  Must be `com.example.happy.birthday` |
|**`message`**| `[string]`   | A birthday message |
|`forUri`     | `[uri]`      | A link |
|`birthday`   | `[datetime]` | The birthday |
|`createdAt`  | `[datetime]` | The time the record was created |

'@ | MarkX

$lexiconMarkdown


$lexiconJson = $lexiconMarkdown.Lexicon | ConvertTo-Json -Depth 5

$lexiconMarkdownExample = @'


To extract out a lexicon from the text above, we can:

~~~PowerShell
$lexiconMarkdown.Lexicon | ConvertTo-Json -Depth 5
~~~

Which gives us:

'@ + @"

~~~json
$lexiconJson
~~~

As you can see, we can take rich data within Markdown and process it into lexicons (or anything else we might want)
"@

$lexiconMarkdownExample | MarkX


$selfHelp = {Get-Help Get-MarkX | MarkX}

$markdownHelp = @"

### Markdown Help

PowerShell commands generally contain help.

We can pipe Get-Help into MarkX to get help as markdown

~~~PowerShell
$selfHelp
~~~

When we run this, we get:

"@

. $selfHelp


$InSummary = @"

## In Summary

MarkX is a simple and powerful tool.
It allows us to turn many objects into Markdown, and turn Markdown into many objects.

Please pay around and see what you can do.

"@ 

$InSummary | MarkX
