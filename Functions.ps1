# Config file for functions

# Display art whenever called
function Show-AsciiArt {
    $asciiArt = @"
     _____                                                                           _____ 
    ( ___ )                                                                         ( ___ )
     |   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|   | 
     |   |     ____  _____ ____ _____ ____ ___ _____ ____    __  __ _  ____     __   |   | 
     |   |    |  _ \| ____/ ___| ____|  _ \_ _|_   _/ ___|  |  \/  | |/ /\ \   / /   |   | 
     |   |    | |_) |  _|| |  _|  _| | | | | |  | | \___ \  | |\/| | ' /  \ \ / /    |   | 
     |   |    |  _ <| |__| |_| | |___| |_| | |  | |  ___) | | |  | | . \   \ V /     |   | 
     |   |    |_| \_\_____\____|_____|____/___| |_| |____/  |_|  |_|_|\_\   \_/      |   | 
     |   |                                                                           |   | 
     |___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___| 
    (_____)                                                                         (_____) 
      
"@

    Write-Host $asciiArt -ForegroundColor Green
}

# Convert language input to proper language code
function Convert-ToLanguageCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage='Language name to be converted.')]
        [string]$LanguageName
    )
    $languageName = $LanguageName.Trim()
    if ($languageCodes.ContainsKey($languageName)) {
        return $languageCodes[$languageName]
    } else {
        Write-Host "Language '$LanguageName' not found in the mapping." -ForegroundColor Red
        Write-Host "Please verify that the language you entered is correct and free of any spelling errors." -ForegroundColor Red
        Write-Host ""
        return $null  # Return null if not found
    }
}

# Convert duration to a more readable format
function Convert-ToHumanReadableDuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage='Duration string extracted from the .json file.')]
        [string]$durationString
    )
    
    # Parse the string into a TimeSpan object
    $timeSpan = [timespan]($durationString -replace '(?<=.\d{7})\d+$')

    switch ($true) {
        ($timeSpan.Minutes -eq 0 -and $timeSpan.Hours -eq 0) {
            $humanReadableTimeSpan = '{0} second(s)' -f $timeSpan.Seconds
            break
        }

        ($timeSpan.Hours -eq 0) {
            $humanReadableTimeSpan = '{0} minutes and {1} second(s)' -f $timeSpan.Minutes, $timeSpan.Seconds
            break
        }

        default {
            $humanReadableTimeSpan = '{0} hours {1} minutes and {2} second(s)' -f $timeSpan.Hours, $timeSpan.Minutes, $timeSpan.Seconds
        }
    }

    return $humanReadableTimeSpan
}

# Gets valid subtitle track IDs
function Get-ValidSubtitleTrackIds {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage='All valid subtitle track IDs identified in the .mkv file.')]
        [array]$ValidIds
    )

    do {
        # Prompt user for subtitle track IDs
        Write-Host "Enter comma-separated subtitle track IDs to keep (or type 'all' to keep all, 'none' to exclude all)" -ForegroundColor Yellow
        $subtitleTrackIds = Read-Host
        $subtitleTrackIds = $subtitleTrackIds.Trim().ToLower()

        # Handle special cases 'all' and 'none'
        if ($subtitleTrackIds -eq "all" -or $subtitleTrackIds -eq "none") {
            return $subtitleTrackIds
        }

        # Validate subtitle track IDs
        $inputIds = $subtitleTrackIds -split ',' | ForEach-Object { $_.Trim() }
        $invalidIds = $inputIds | Where-Object { $_ -notin $ValidIds }

        if ($invalidIds.Count -gt 0) {
            Write-Host "Invalid subtitle track IDs detected: $($invalidIds -join ', '). Please enter valid IDs." -ForegroundColor Red
        }
        else {
            return $subtitleTrackIds
        }
    }
    while ($true) # Loop indefinitely until valid input or special cases
}