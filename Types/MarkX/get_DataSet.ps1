if ($this.'#DataSet') {return $this.'#DataSet' }

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

return $this.'#DataSet'
