describe MarkX {
    context 'Markdown and XML' {
        it 'Gets markdown as XML' {
            "# Hello world" | 
                MarkX | 
                    Select-Object -ExpandProperty InnerText |
                        Should -Be 'Hello World'
        }

        it 'Can change' {
            $markx = "# Hello world" | MarkX
            
            $markx | 
                    Select-Object -ExpandProperty InnerText |
                        Should -Be 'Hello World'

            $markx.Markdown = '# I can change'
            $markx | 
                    Select-Object -ExpandProperty InnerText |
                        Should -Be 'I can change'
        }

        it 'Can contain tables' {
            $markx = "|a|b|c|","|-|-|-|", "|1|2|3|" | MarkX 
            
            $markx.DB.Tables[0].Rows[0].a | Should -Be 1
            $markx.DB.Tables[0].Columns[0].DataType | Should -Not -Be ([string])
            
            $markx.DB.Tables[0].Rows[0].b | Should -Be 2
            
            $markx.DB.Tables[0].Rows[0].c | Should -Be 3
        }
    }

    context 'Tables from objects' {
        it 'Keeps each value under its own column when property order differs' {
            $markx = [PSCustomObject]@{ a = 1; b = 2 }, [PSCustomObject]@{ b = 3; a = 4 } | MarkX

            $markx.DB.Tables[0].Rows[1].a | Should -Be 4
            $markx.DB.Tables[0].Rows[1].b | Should -Be 3
        }

        it 'Adds a column for a property that only a later row has' {
            $markx = [PSCustomObject]@{ a = 1; b = 2 }, [PSCustomObject]@{ a = 3; b = 4; c = 5 } | MarkX

            @($markx.Markdown -split '\r?\n') -join '/' | Should -Be '|a|b|c|/|-|-|-|/|1|2||/|3|4|5|'
        }

        it 'Leaves an empty cell for a property a row does not have' {
            $markx = [PSCustomObject]@{ a = 1; b = 2 }, [PSCustomObject]@{ a = 3 } | MarkX

            @($markx.Markdown -split '\r?\n') -join '/' | Should -Be '|a|b|/|-|-|/|1|2|/|3||'
        }

        it 'Gives every hashtable key a column, as in the README example' {
            # Hashtable keys enumerate in no fixed order, so the test looks cells up by header name.
            $markx = @{ n1 = 1; n2 = 2 }, @{ n1 = 2; n3 = 3 } | MarkX
            $rows = foreach ($line in @($markx.Markdown -split '\r?\n')) {
                , @(($line -replace '^\||\|$') -split '\|')
            }
            $header, $null, $firstRow, $secondRow = $rows
            $columnOf = @{}
            foreach ($columnName in $header) { $columnOf[$columnName] = $columnOf.Count }

            @($header | Sort-Object) -join ',' | Should -Be 'n1,n2,n3'
            $firstRow[$columnOf.n3] | Should -Be ''
            $secondRow[$columnOf.n2] | Should -Be ''
            $secondRow[$columnOf.n3] | Should -Be 3
        }
    }
}
