<#
.SYNOPSIS
    Gets Markdown date with git
.DESCRIPTION
    Gets the Markdown date, according to it's git history.
.NOTES
    The date will be the first history entry for the file
#>
param()

$thisDate = $this.Date
if ($thisDate) { return $thisDate }

$gitCommand = $ExecutionContext.SessionState.InvokeCommand.GetCommand('git', 'Application')
if ($gitCommand) {
    $gitDates = 
        @(try {
            # we can use `git log -n 1 --reverse --format=%ci` to get the first date
            # (this does not account for file moves, as that is slower)
            (& $gitCommand -C (
                "$($this.Path | Split-Path)"
            ) log -n 1 --reverse --format=%ci --date default $this.Path *>&1) -as [datetime[]]
        } catch {
            $null
        })
    # Because the file might not be in git, we want to always set the `$LASTEXITCODE` to 0
    $LASTEXITCODE = 0
    # Set the date to the last date we find.
    if ($gitDates) {
        $this.Date = $gitDates[-1]
        return $this.header.date
    }
}
