$currentRows = @()

$allMarkdown = @(:nextInput foreach ($md in $this.Input) {    
    if ($md -isnot [string]) {
        # If the markdown was a file
        if ($md -is [IO.FileInfo] -and 
            # and it had the extension .md or markdown
            $md.Extension -in '.md', '.markdown') {
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
        $md = Get-Content -Raw $md
    }

    $yamlheader = ''
    if ($md -match '^---') {
        $null, $yamlheader, $md = $in -split '---', 3
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

$tables = $this.'#XML' | Select-Xml //table
filter innerText {
    $in = $_
    if ($in -is [string]) { "$in" }
    elseif ($in.innerText) { "$($in.innerText)" }
    elseif ($in.'#text') { "$($in.'#text')" }
}

function bestType {
    $allIn = @($input) + @(if ($args) { $args})
    switch ($true) {        
        { $allIn -as [float[]] } {
            [float]; break
        }
        { $allIn -as [double[]] } {
            [double]; break
        }
        { $allIn -as [long[]] } {
            [long]; break
        }
        { $allIn -as [ulong[]] } {
            [uint32]; break
        }
        { $allIn -as [decimal[]] } {
            [decimal]; break
        }                        
        { $allIn -as [timespan[]] } {
            [timespan]; break
        }                
        { $allIn -as [DateTime[]] } {
            [DateTime]; break
        }
        default {
            [string]
        }
    }            
}

$markdownData = [Data.DataSet]::new('MarkX')
$tableNumber = 0
foreach ($table in $tables) {
    $tableNumber++
    $markdownDataTable  = $markdownData.Tables.Add("MarkdownTable$tableNumber")
    
    [string[]]$PropertyNames = @( $table.Node.thead.tr.th | innerText )

    # We want to upcast our datatable as much as possible
    # so we need to collect the rows first
    $TableDictionary = [Ordered]@{}
    $propertyIndex = 0
    foreach ($property in $propertyNames) {        
        $TableDictionary[$property] = @(
            foreach ($row in $table.Node.tbody.tr) {
                @($row.td)[$propertyIndex] | innerText
            }
        )
        $propertyIndex++
    }    

    # Now that we have all of the data collected,
    $markdownDataTable.Columns.AddRange(@(        
        foreach ($property in $propertyNames) {
            $propertyIndex = 0
            $bestType = $TableDictionary[$property] | bestType
            [Data.DataColumn]::new($property, $bestType, '', 'Attribute')
        }
        [Data.DataColumn]::new('tr', [xml.xmlelement], '', 'Hidden')
    ))
        
    foreach ($row in $table.Node.tbody.tr) {
        $propertyValues = @(            
            $row.td | innerText
            $row
        )
        $null = $markdownDataTable.Rows.Add($propertyValues)
    }

    $previous = $table.Node.PreviousSibling
    if ($previous.LocalName -eq 'blockquote') {
        $markdownDataTable.ExtendedProperties.Add("description", $previous.InnerText)
        $previous = $previous.PreviousSibling
    }
    if ($previous.LocalName -match 'h[1-6]') {
        $markdownDataTable.TableName = $previous.InnerText
    }
}

$this | Add-Member NoteProperty '#DataSet' $markdownData -Force
