<#
.SYNOPSIS
    Gets Markdown DataSets
.DESCRIPTION
    Gets Markdown tables as a dataset
#>
param()

# If we already have a data set, return it.
if ($this.'#DataSet') {return $this.'#DataSet' }

# If we could not coerce the markdown into XML,
# there is no dataset.
if (-not $this.'#XML') { return  }

# Query all table elements within the markdown
$tables = $this.'#XML' | Select-Xml //table

# Make a quick little filter to get at the inner text
filter innerText {
    $in = $_
    # PowerShell presents inner text in three ways:
    # 1. As a string property.
    if ($in -is [string]) { "$in" }
    # 2. As an element with an innerText property.
    elseif ($in.innerText) { "$($in.innerText)" }
    # 3. As a property bag with a `#text` property.
    elseif ($in.'#text') { "$($in.'#text')" }
}

# Create another filter to try to upcast things
function bestType {
    # We will do this by taking all of the input as an array
    # and casting to various strongly typed arrays.        
    $allIn = @($input) + @(if ($args) { $args})    
    # In order of preference, that is:
    switch ($true) {
        # * `[float]`
        { $allIn -as [float[]] } {            
            [float]; break
        }
        # * `[double]`
        { $allIn -as [double[]] } {
            [double]; break
        }
        # * `[decimal]`
        { $allIn -as [decimal[]] } {
            [decimal]; break
        }
        # * `[long]`
        { $allIn -as [long[]] } {
            [long]; break
        }
        # * `[ulong]`
        { $allIn -as [ulong[]] } {
            [uint32]; break
        }        
        # * `[timespan]`
        { $allIn -as [timespan[]] } {
            [timespan]; break
        }
        # * `[DateTime]`
        { $allIn -as [DateTime[]] } {
            [DateTime]; break
        }        
        default {
            # * `[string]`
            [string]
        }
    }            
}

# Create a new dataset
$markdownData = [Data.DataSet]::new('MarkX')
# Keep track of our table number, since tables may not have names.
$tableNumber = 0
foreach ($table in $tables) {
    $tableNumber++
    $markdownDataTable  = $markdownData.Tables.Add("MarkdownTable$tableNumber")
    
    # Get our table headers' inner text.
    # These are our property names.
    [string[]]$PropertyNames = @( $table.Node.thead.tr.th | innerText )

    # We want to upcast our datatable as much as possible
    # so we need to collect the rows first

    # We will put them in a dictionary
    $TableDictionary = [Ordered]@{}
    $propertyIndex = 0
    # Walk over each property name
    foreach ($property in $propertyNames) {
        # get all values in this column as inner Text
        $TableDictionary[$property] = @(
            foreach ($row in $table.Node.tbody.tr) {
                @($row.td)[$propertyIndex] | innerText
            }
        )
        # and move onto the next property.
        $propertyIndex++
    }    

    # Now that we have all of the data collected,
    $markdownDataTable.Columns.AddRange(@(
        # we can create the data columns
        foreach ($property in $propertyNames) {            
            $propertyIndex = 0
            $bestType = $TableDictionary[$property] | bestType
            [Data.DataColumn]::new($property, $bestType, '', 'Attribute')
        }
        # We will always add one more column that contains the table row
        # Because this cannot always be serialized, we will hide it from the schema.
        [Data.DataColumn]::new('tr', [xml.xmlelement], '', 'Hidden')
    ))
        
    # Now we need to walk over each row.
    foreach ($row in $table.Node.tbody.tr) {
        # and get the values as inner text
        $propertyValues = @(            
            $row.td | innerText
            $row
        )
        # and add them.
        # PowerShell will cast the values to the appropriate types for the table.
        $null = $markdownDataTable.Rows.Add($propertyValues)
    }

    # Now, for bonus points, check to see if we have a description.
    # We can get a description from the previous sibling
    $previous = $table.Node.PreviousSibling
    # If it was a blockquote, that counts.
    if ($previous.LocalName -eq 'blockquote') {
        $markdownDataTable.ExtendedProperties.Add("description", $previous.InnerText)
        $previous = $previous.PreviousSibling
    }
    # Last but not least, we can derive a table name from a previous header.
    if ($previous.LocalName -match 'h[1-6]') {
        $markdownDataTable.TableName = $previous.InnerText
    }
}

# Cache our dataset to the object so we do not have to recompute it each tiem.
$this | Add-Member NoteProperty '#DataSet' $markdownData -Force

# And return the cached dataset.
return $this.'#DataSet'