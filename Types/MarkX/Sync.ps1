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

$allMarkdown = @(:nextInput foreach ($md in $this.Input) {    
    if ($md -isnot [string]) {
        # If the markdown was a file
        if ($md -is [IO.FileInfo] -and 
            # and it had the extension .md or markdown
            $md.Extension -in '.md', '.markdown', '.mdx') {
            $this | Add-Member NoteProperty '#Path' $md.Fullname -Force        
            $md = Get-Content -LiteralPath $md.Fullname -Raw 
            $md
            continue
        }
        
        if ($md -is [Management.Automation.CommandInfo]) {
            $cmdHelp = if (
                $md -is [Management.Automation.FunctionInfo] -or
                $md -is [Management.Automation.AliasInfo]
            ) {
                Get-Help -Name $md.Name
            } elseif ($md -is [Management.Automation.ExternalScriptInfo]) {
                Get-Help -Name $md.Source
            } else {
                continue nextInput
            }
            if ($cmdHelp) {
                $md = $cmdHelp                
            }
        }

        if ($md.pstypenames -match 'HelpInfo') {
            @(
                if ($md.Name -match '[\\/]') {
                    "# $(@($md.Name -split '[\\/]')[-1] -replace '\.ps1')"
                } else {
                    "# $($md.Name)"
                }
                
                if ($md.Synopsis) {
                    "## $($md.Synopsis)"
                }                
                $description = $md.Description.text -join [Environment]::NewLine
                if ($description) {
                    "### $($description)"
                }
                
                $md.alertset.alert.text -join [Environment]::NewLine
                
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
    if ($md -match '^---') {
        $null, $yamlheader, $restOfMakdown = $md -split '---', 3
        if ($yamlheader) {
            $yamlHeaders+= $yamlheader
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

$mdPipelineBuilder = [Markdig.MarkdownPipelineBuilder]::new()
$mdPipeline = [Markdig.MarkdownExtensions]::UsePipeTables($mdPipelineBuilder).Build()

$this | 
    Add-Member NoteProperty '#HTML' (
        [Markdig.Markdown]::ToHtml($markdown, $mdPipeline)
    ) -Force

$this | 
    Add-Member NoteProperty '#XML' (
        "<xhtml>$($this.'#HTML')</xhtml>" -as [xml]
    ) -Force

if (-not $this.'#XML') { return }

$this.psobject.Properties.Remove('#DataSet')
