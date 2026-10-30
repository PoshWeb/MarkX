<#
.SYNOPSIS
    Converts objects to tables
.DESCRIPTION
    Converts objects to markdown tables.

    The columns are every key or property found in any row, in the order they are first seen.
    Each row is written in column order, with an empty cell wherever a row has no value for a column.
#>
param(
# The rows in the table.
[PSObject[]]
$Rows
)

$allInput = @($input)
$allRows = @($allInput) + $(if ($Rows) {
    $rows
})

# Normalize each row into a dictionary of column name to value,
# collecting the column names in the order they are first seen.
$columnNames = [Collections.Generic.List[string]]::new()
$normalizedRows = @(
    foreach ($row in $Rows) {
        $values = [Ordered]@{}
        if ($row -is [Collections.IDictionary]) {
            # take all keys from the dictionary
            foreach ($key in $row.Keys) {
                $values["$key"] = $row[$key]
            }
        } else {
            # Otherwise, walk over all properties on the object
            foreach ($psProp in $row.psobject.properties) {
                $values[$psProp.Name] = $psProp.Value
            }
        }
        foreach ($columnName in $values.Keys) {
            if (-not $columnNames.Contains($columnName)) {
                $columnNames.Add($columnName)
            }
        }
        $values
    }
)

# Each line of the table is output as it is built, so the lines collect without appending to an array.
$markdownLines = @(
    if ($normalizedRows.Count) {
        # Create the header
        '|' + (@($columnNames) -replace ([Environment]::newline), '<br/>' -replace '\|', '\|' -join '|') + '|'
        # Then create the alignment row.
        '|' + (@(foreach ($columnName in $columnNames) { '-' * $columnName.Length }) -join '|') + '|'
        # Now create the row for each object, in column order.
        foreach ($values in $normalizedRows) {
            # one cell per column, empty when the row has no such column
            $cells = foreach ($columnName in $columnNames) {
                if ($values.Contains($columnName)) { "$($values[$columnName])" } else { '' }
            }
            '|' + (@($cells) -replace ([Environment]::newline), '<br/>' -replace '\|', '\|' -join '|') + '|'
        }
    }
)
$markdownLines
