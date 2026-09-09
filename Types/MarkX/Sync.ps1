<#
.SYNOPSIS
    Synchronizes Mark Data
.DESCRIPTION
    Synchronizes a MarkX input into a parsed MarkX file.
.NOTES
    This will read markdown from files, convert them from markdown,
    and attempt to cast the output to XHTML so it can be queried.    
#>
$currentRows = @()

$markXProtoType = [PSCustomObject]@{PSTypeName='MarkX'}

$allMarkdown = @(:nextInput foreach ($md in $this.Input) {    
    if ($md -isnot [string]) {
        if ($md -is [IO.DirectoryInfo]) {
            $this |
                Add-Member NoteProperty '#Path' $md.Fullname -Force
            $this.Site = "$($md.FullName)"
            continue nextInput
        }
        # If the markdown was a file
        if ($md -is [IO.FileInfo] -and 
            # and it had a markdown extension
            $md.Extension -in $markXProtoType.MarkdownExtension) {

            $this |
                Add-Member NoteProperty '#Path' $md.Fullname -Force

            $md = Get-Content -LiteralPath $md.Fullname -Raw
            $md
            continue
        }

        if ($md -is [ScriptBlock]) {
            ${function:Lambda λ} = $md
            $md = $ExecutionContext.SessionState.InvokeCommand.GetCommand('Lambda λ', 'Function')
        }
        
        if ($md -is [Management.Automation.CommandInfo]) {
            $cmdHelp = if (
                $md -is [Management.Automation.FunctionInfo] -or
                $md -is [Management.Automation.AliasInfo]
            ) {
                Get-Help -Name $md.Name
            } elseif ($md -is [Management.Automation.ExternalScriptInfo]) {
                $this | Add-Member NoteProperty '#Path' "$($md.Source)" -Force
                Get-Help -Name $md.Source
            } else {
                continue nextInput
            }                        

            $thisScriptBlock = 
                if ($this -is [ScriptBlock]) {
                    $this
                } elseif ($this.ScriptBlock) {
                    $this.ScriptBlock
                }

            if ($thisScriptBlock) {    
                $frontMatter = @(foreach ($attr in $thisScriptBlock.Attributes) {
                    if ($attr -is [Reflection.AssemblyMetaDataAttribute] -and
                        $attr.Key -match 'Front[\s\p{P}]{0,}Matter') {
                        $attr.Value
                    }   
                })
                if ($frontMatter) {
                    $this | Add-Member NoteProperty '#FrontMatter' $frontMatter -Force
                }
            }

            if ($cmdHelp) {
                $md = $cmdHelp
            }
        }

        if ($md.pstypenames -match 'HelpInfo') {
            $helpObject = [Ordered]@{
                title = $(
                    if ($md.Name -match '[\\/]') {
                        "$(@($md.Name -split '[\\/]')[-1] -replace '\.ps1')"
                    } else {
                        "$($md.Name)"
                    }
                )
                synopsis = $md.synopsis
                description = $md.Description.text -join [Environment]::NewLine
                notes = $md.alertset.alert.text -join [Environment]::NewLine
                inputs = $md.inputTypes.inputType.type.name -join [Environment]::NewLine
                outputs = $md.returnValues.returnValue.type.name -join [Environment]::NewLine
                examples = @(
                    foreach ($example in $md.examples.example) {
                        $exampleNumber++
                        # Combine the code and remarks
                        $exampleLines = 
                            @(
                                $example.Code
                                foreach ($remark in $example.Remarks.text) {
                                    if (-not $remark) { continue }
                                    $remark
                                }
                            ) -join ([Environment]::NewLine) -split '(?>\r\n|\n)' # and split into lines

                        # Anything until the first non-comment line is a markdown predicate to the example
                        $nonCommentLine = $false
                        $markdownLines = @()

                        # Go thru each line in the example as part of a loop
                        $codeBlock = @(foreach ($exampleLine in $exampleLines) {
                            # Any comments until the first uncommentedLine are markdown
                            if ($exampleLine -match '^\#' -and -not $nonCommentLine) {
                                $markdownLines += $exampleLine -replace '^\#' -replace '^\s+'
                            } else {
                                $nonCommentLine = $true
                                $exampleLine
                            }
                        }) -join [Environment]::NewLine
                        
                        # Join all of our markdown lines together                        
                        $markdownLines -join [Environment]::NewLine
                        "~~~PowerShell"
                        $codeBlock
                        "~~~"
                    }
                ) -join [Environment]::NewLine
                source = 
                    if ($this -is [ScriptBlock]) {
                        $this.Ast.ToString()
                    } elseif ($this.ScriptBlock) {
                        "$($this.ScriptBlock.Ast.ToString())"
                    }
            }

            @(                                
                "# $($helpObject.title)"
                
                if ($md.Synopsis) {
                    "## $($md.Synopsis)"
                }
                
                if ($helpObject.description) {
                    "### $($helpObject.description)"
                    [Environment]::NewLine
                }

                if ($helpObject.inputs) {
                    "### Inputs"
                    [Environment]::NewLine
                    $helpObject.inputs
                    [Environment]::NewLine
                }

                if ($helpObject.outputs) {
                    "### Outputs"
                    $helpObject.outputs
                    [Environment]::NewLine
                }

                if ($helpObject.notes) {
                    if (-not ($helpObject.inputs -or $helpObject.outputs)) {
                        "### Notes"
                    }
                    $helpObject.notes
                    [Environment]::NewLine
                }                                
                
                [Environment]::NewLine
                $helpObject.examples
                [Environment]::NewLine

                if ($helpObject.source -and 
                    -not ($helpObject.source -match '(?m)^(?>~~~|```)PowerShell')
                ) {
                    "<details><summary>View Source</summary>"
                    ""                    
                    "~~~PowerShell"
                    $helpObject.Source
                    "~~~"
                    "</details>"
                    [Environment]::NewLine
                }
            ) -join [Environment]::NewLine

            $header = $this.Header

            if (-not $header) {
                $this.Header = $helpObject
            } elseif ($header -isnot [string]) {
                foreach ($key in $helpObject.Keys) {
                    if (-not $header[$key]) {
                        $header[$key] = $helpObject[$key]
                    }
                }
                $this.Header = $header
            }
            continue nextInput
        }        
        if ($md -is [ScriptBlock]) {
            "<pre><code class='language-powershell'>$(
                [Web.HttpUtility]::HtmlEncode(
                    "$md"
                )
            )</code><pre>"
            continue nextInput
        } 
        if ($md -is [Collections.IDictionary] -or 
            ($md.GetType -and 
                (-not $md.GetType().IsPrimitive)
            )  
        ) {            
            $currentRows += $md            
            continue
        }        
    }
    
    if ($currentRows) {    
        $this.ToTable($currentRows)        
        $currentRows = @()
    }

    if ($md -match '(?>\.md|markdown)$' -and
        (
            [IO.File]::Exists("$md") -or 
            (Test-Path $md -ErrorAction Ignore)
        )        
    ) {
        $resolvedPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($md)
        $this | Add-Member NoteProperty '#Path' "$resolvedPath" -Force
        $md = Get-Content -Raw $md
    }

    $yamlheader = ''
    if ($md -match '^---') {
        $null, $yamlheader, $md = $md -split '---', 3
        if ($yamlheader) {
            $this | Add-Member NoteProperty '#YamlHeader' $yamlheader -Force
        }
    }

    $md
})

if ($currentRows) {    
    $allMarkdown += $this.ToTable($currentRows)
    $currentRows = @()
}

$yamlHeaders = @()
$allMarkdown = @(foreach ($md in $allMarkdown) {    
    if ($md -match '^[\-\+]{3}') {
        $null, $frontMatter, $restOfMakdown = $md -split '[\-\+]{3}', 3
        
        $this | Add-Member NoteProperty '#FrontMatter' $frontMatter -Force

        if ($frontMatter) {
            $yamlHeaders+=$frontMatter
        }
        $restOfMakdown
    } else {
        $md
    }
})

if ($yamlHeaders) {
    $yamlHeader = $yamlHeaders -join (
        [Environment]::NewLine + '---' + [Environment]::NewLine
    )
    $this | Add-Member NoteProperty '#YamlHeader' $yamlHeader -Force
}

$markdown = $allMarkdown -join [Environment]::NewLine

$this | 
    Add-Member NoteProperty '#Markdown' $Markdown -Force

$Markdown = $this.'#Markdown'

if (-not $Markdown) { return }

$mdPipelineBuilder = 
    [Markdig.MarkdownExtensions]::UseYamlFrontMatter(
        [Markdig.MarkdownExtensions]::UseAdvancedExtensions(
            [Markdig.MarkdownPipelineBuilder]::new()
        )
    )

$mdPipeline = $mdPipelineBuilder.Build()

$this | 
    Add-Member NoteProperty '#HTML' (
        [Markdig.Markdown]::ToHtml($markdown, $mdPipeline) -replace '\sdisabled="disabled"'
    ) -Force

$this | 
    Add-Member NoteProperty '#XML' (
        "<xhtml>$($this.'#HTML')</xhtml>" -as [xml]
    ) -Force

if (-not $this.'#XML') { return }

$this.psobject.Properties.Remove('#DataSet')
