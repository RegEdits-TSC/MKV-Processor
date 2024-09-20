<#
.SYNOPSIS
    A PowerShell script for processing MKV files using MKVToolNix (mkvmerge).
    The script renames video and audio tracks, modifies track languages, and manages subtitle tracks based on user input.

.DESCRIPTION
    This script automates the processing of MKV files by utilizing MKVToolNix's mkvmerge tool. 
    It allows users to modify video and audio track names, set languages, and manage subtitle tracks.
    Users can choose to keep all subtitles, remove them, or select specific tracks.
    The script includes options to skip certain steps, and it handles errors and user input validation to ensure smooth operation.

.AUTHOR
    RegEdits

.COPYRIGHT
    © 2024 RegEdits Torrenting. All rights reserved.

.NOTES
    Ensure that MKVToolNix is installed and that the mkvmerge executable path is correctly set in the script.
    This script is designed for use in environments where MKV files are routinely processed and requires PowerShell 5.1.
#>

# __        ___    ____  _   _ ___ _   _  ____ 
# \ \      / / \  |  _ \| \ | |_ _| \ | |/ ___|
#  \ \ /\ / / _ \ | |_) |  \| || ||  \| | |  _ 
#   \ V  V / ___ \|  _ <| |\  || || |\  | |_| |
#    \_/\_/_/   \_\_| \_\_| \_|___|_| \_|\____|
#
# Modifications below this point may result in script failure. 
# Please proceed with caution and only make changes if you fully understand the implications.
#

# Defining parameters for file paths
Param (
    [Parameter(HelpMessage='Specify the full path to the input directory.')]
    [string]$inputPath = "D:\Movies & Show Sorting\Sort",

    [Parameter(HelpMessage='Specify the full path to the output directory.')]
    [string]$outputPath = "D:\Movies & Show Sorting\Sorted",

    [Parameter(HelpMessage='Specify the full path to the mkvmerge executable.')]
    [string]$mkvmergePath = "C:\Program Files\MKVToolNix\mkvmerge.exe",

    [Parameter(HelpMessage='Specify the full path to the Config.ps1 file.')]
    [string]$configPath = ".\Config.ps1",

    [Parameter(HelpMessage='Specify the full path to the Functions.ps1 file.')]
    [string]$functionsPath = ".\Functions.ps1"
)

# START OF MKV PROCESSING SCRIPT
Clear-Host

Write-Host "Importing configuration and function dependencies..." -ForegroundColor Yellow
Write-Host ""
Start-Sleep 2

# Test config path and import
if (Test-Path -Path $configPath) {
    . $configPath
    Write-Host "Successfully imported: $configPath" -ForegroundColor Green
} else {
    Write-Host "File not found: $configPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "The script will now close in 10 seconds..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 10
    exit
}

Start-Sleep 1

# Test functions path and import
if (Test-Path -Path $functionsPath) {
    . $functionsPath
    Write-Host "Successfully imported: $functionsPath" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "File not found: $functionsPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "The script will now close in 10 seconds..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 10
    exit
}

Start-Sleep 1
Write-Host "All necessary imports completed..." -ForegroundColor Yellow
Start-Sleep 3
Clear-Host

# Display the ASCII art
Show-AsciiArt
Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking directories..." -ForegroundColor Yellow
Write-Host ""
Start-Sleep 3

# Create array of paths for testing
$paths = @($inputPath, $outputPath)

# Tests both input and output path to make sure they exist
foreach ($path in $paths) {
    if (Test-Path -Path $path) {
        Write-Host "The directory '$path' exists and works." -ForegroundColor Green
    } else {
        Write-Host "The directory '$path' does not exist or the path is invalid." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script will now close in 10 seconds..." -ForegroundColor Yellow

        Start-Sleep -Seconds 10
        exit
    }
    Start-Sleep 1
}

Write-Host ""

# Loop to require the user to enter a valid release group name with no spaces
do {
    try {
        Write-Host "Please enter the release group name (no spaces allowed & case-sensitive)" -ForegroundColor Yellow
        $releaseGroup = Read-Host

        if ([string]::IsNullOrWhiteSpace($releaseGroup) -or $releaseGroup -match "\s") {
            throw "The release group name cannot be empty or contain spaces. Please try again."
        }
        $validInput = $true
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        $validInput = $false
    }
} while (-not $validInput)

Write-Host ""
Write-Host "Release group set to: $releaseGroup" -ForegroundColor Green
Write-Host ""
Start-Sleep 1

# Set videoLanguageCode value to keep value after loop processes
$videoLanguageCode = ""

do {
	Write-Host "Please enter the video(s) language" -ForegroundColor Yellow
	$videoLanguage = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($videoLanguage)) {
        Write-Host "A video language is required. Please try again." -ForegroundColor Red
        continue
    } elseif ($videoLanguage -notmatch "^[a-zA-Z\s,-]+$") {
        Write-Host "The video language can only contain letters, spaces, commas and dashes. Please try again." -ForegroundColor Red
        continue
    }

    # Convert language to its 3-letter code
    $videoLanguageCode = Convert-ToLanguageCode -LanguageName $videoLanguage
} while ([string]::IsNullOrWhiteSpace($videoLanguageCode))

Write-Host ""
Write-Host "Video language set to: $videoLanguage | $videoLanguageCode" -ForegroundColor Green
Write-Host ""
Start-Sleep 1

### SUBTITLE SELECT SECTION

# Prompt user to skip or parse through subtitle tracks for manual selection
Write-Host "Would you like to skip subtitle track selection?" -ForegroundColor Yellow

# Use a simple prompt for the user's choice
$subsChoices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$subsChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Select this option to skip the subtitle track selection. All subtitle tracks will be kept.'))
$subsChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No', 'Select this option if you want to choose specific subtitle tracks to keep.'))

# Prompt user for choice without displaying choices again
$subsDecision = $Host.UI.PromptForChoice('', '', $subsChoices, 0)  # Empty strings for title and question in PromptForChoice

# Set track ID in case user wants to skip selection
$subtitleTrackIds = ""

if ($subsDecision -eq 0) {
    $subtitleTrackIds = "skip"

    Write-Host ""
    Write-Host "Subtitle track selection skipped. All subtitle tracks will be kept." -ForegroundColor Green
} else {
    # Script will continue and not skip subtitle track selection
    Write-Host ""
    Write-Host "User will be prompted for each MKV file to make a decision regarding which subtitle tracks to retain or exclude." -ForegroundColor Green
}

### TITLE NAMING SELECT SECTION
Start-Sleep 1
Write-Host ""

# Prompt user to skip or parse through file title renaming process
Write-Host "Would you prefer to bypass the file title renaming process for each file?" -ForegroundColor Yellow

# Use a simple prompt for the user's choice
$titleChoices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$titleChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Choose this option to bypass renaming the file title for each individual file.'))
$titleChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No', 'Choose this option if you wish to rename the file title for each individual file.'))

# Prompt user for choice without displaying choices again
$titleDecision = $Host.UI.PromptForChoice('', '', $titleChoices, 1)  # Empty strings for title and question in PromptForChoice

# Set track ID in case user wants to skip selection
$fileTitleRename = ""

if ($titleDecision -eq 0) {
    $fileTitleRename = "skip"

    Write-Host ""
    Write-Host "File title renaming has been skipped. The default file title will be retained." -ForegroundColor Green
} else {
    # Script will continue and not skip subtitle track selection
    Write-Host ""
    Write-Host "User will be prompted to input the file title before each file is processed." -ForegroundColor Green
}

Write-Host ""
Start-Sleep 2
Write-Host "Script will now begin..." -ForegroundColor Yellow
Start-Sleep 3
Clear-Host

# Get all .mkv files from the input path
$mkvFiles = Get-ChildItem -LiteralPath $inputPath -Filter *.mkv

# Clear terminal to begin
Clear-Host
Write-Host ""

# Display the ASCII art
Show-AsciiArt
Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Clear terminal to begin main script
Clear-Host

# Loop through each .mkv file
foreach ($file in $mkvFiles) {
    $inputFile = $file.FullName
    $tempFile = [System.IO.Path]::Combine($outputPath, "$($file.BaseName)_temp.mkv")

    # Display the ASCII art
    Show-AsciiArt
    Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Processing file..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Write-Host "$file" -ForegroundColor Green
    Start-Sleep -Seconds 2
    Write-Host ""
    Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan

    # Set file title so it can be used later in the script
    $fileTitle = $null

    # Use the function to ensure valid input (or skip if value already set at beginning of script)
    if ($fileTitleRename -eq "skip") {
        break # File title rename skipped, continue with script
    } else {
        # Loop to require the user to enter a valid file title with no spaces
        do {
            try {
                Write-Host "Please enter the file title (no spaces allowed & case-sensitive)" -ForegroundColor Yellow
                $fileTitle = Read-Host

                if ([string]::IsNullOrWhiteSpace($fileTitle) -or $fileTitle -match "\s") {
                    throw "The file title cannot be empty or contain spaces. Please try again."
                }
                $validInput = $true
            } catch {
                Write-Host $_.Exception.Message -ForegroundColor Red
                Write-Host ""
                $validInput = $false
            }
        } while (-not $validInput)
        Clear-Host
    }

    # Display the ASCII art
    Show-AsciiArt
    Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Processing file..." -ForegroundColor Yellow
    Write-Host "$file" -ForegroundColor Green
    Write-Host ""
    Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan

    # Fetch track info with --identify and --identification-format json
    $trackInfoJson = & "$mkvmergePath" --identify --identification-format json "`"$inputFile`""

    # Convert JSON string to PowerShell object
    $trackInfo = $trackInfoJson | ConvertFrom-Json

    # Extract and display Movie/Show Name from container
    $movieShowName = $trackInfo.container.properties.title

    if ([string]::IsNullOrWhiteSpace($movieShowName)) {
        if ($null -ne $fileTitle) {
            $movieShowName = "No Name - ($fileTitle)"
        } else {
            $movieShowName = "No Name"
        }
    } elseif ($null -ne $fileTitle) {
        $movieShowName = "$movieShowName - ($fileTitle)"
    }

    Write-Host "Movie/Show Name: $movieShowName" -ForegroundColor Yellow
    Write-Host ""

    # Initialize the variable at the beginning of each loop iteration
    $audioTrackRenameArg = ""

    # Loop through each track and format the output
    foreach ($track in $trackInfo.tracks) {
        Write-Host "Track ID: $($track.id)" -ForegroundColor Yellow
        
        # Extract title or set a default if not present
        $title = if ($track.properties.track_name) { $track.properties.track_name } else { "No title" }

        # Extract type or set a default if not present
        $type = if ($track.type) { $track.type } else { "Unknown type" }
        $codec = $track.codec

        # Display title, type, and language
        Write-Host "Title/Name: $title" -ForegroundColor Yellow
        Write-Host "Type: $type" -ForegroundColor Yellow
        Write-Host "Language: $($track.properties.language)" -ForegroundColor Yellow

        # If the track is video, also display resolution, frame rate, codec, and duration
        if ($type -eq "video") {
            $resolution = if ($track.properties.pixel_dimensions) { $track.properties.pixel_dimensions } else { "Unknown resolution" }
            $frameRate = if ($track.properties.default_duration) { [math]::Round(1000000000 / $track.properties.default_duration, 2) } else { "Unknown frame rate" }
            $codecInfo = if ($track.codec) { $track.codec } else { "Unknown codec" }
            $duration = if ($track.properties.tag_duration) { Convert-ToHumanReadableDuration -durationString $track.properties.tag_duration } else { "Unknown duration" }

            Write-Host "Resolution: $resolution" -ForegroundColor Yellow
            Write-Host "Frame Rate: $frameRate fps" -ForegroundColor Yellow
            Write-Host "Codec: $codecInfo" -ForegroundColor Yellow
            Write-Host "Duration: $duration" -ForegroundColor Yellow
        }

        # If the track is audio, also display audio channels and bitrate
        if ($type -eq "audio") {
            $audioChannels = if ($track.properties.audio_channels) { $track.properties.audio_channels } else { "Unknown channels" }
            $samplingFrequency = if ($track.properties.audio_sampling_frequency) { $track.properties.audio_sampling_frequency } else { "Unknown frequency" }
            $tagBps = if ($track.properties.tag_bps) { $track.properties.tag_bps } else { "Unknown bitrate" }
            $tagKbps = if ($tagBps -ne "Unknown bitrate") { [math]::Round($tagBps / 1000, 2) } else { "N/A" }

            Write-Host "Audio Channels: $audioChannels" -ForegroundColor Yellow
            Write-Host "Sampling Frequency: $samplingFrequency Hz" -ForegroundColor Yellow
            Write-Host "Bitrate: $tagKbps kbps" -ForegroundColor Yellow

            # Set audio codec
            $codec = $track.codec

            if (-not [string]::IsNullOrWhiteSpace($codec)) {
                # Find the new name for the audio track based on codec
                $newName = if ($codecNames.ContainsKey($codec)) { $codecNames[$codec] } else { "Generic Audio" }

                # Include renaming in the mkvmerge command
                $audioTrackRenameArg = "$($track.id):$newName"

                # DEBUGGING AUDIO TRACK RENAME
                #Write-Host "Audio Track ID: $($track.id) will be named as: $newName" -ForegroundColor Yellow
            } else {
                # DEBUGGING AUDIO TRACK RENAME
                #Write-Host "No codec information available for Track ID: $($track.id)" -ForegroundColor Red
            }
        }

        # If the track is a subtitle, also display enabled and default track status
        if ($type -eq "subtitles") {
            $enabledTrack = if ($null -ne $track.properties.enabled_track) { $track.properties.enabled_track } else { "Unknown" }
            $defaultTrack = if ($null -ne $track.properties.default_track) { $track.properties.default_track } else { "Unknown" }
            $encoding = if ($track.properties.encoding) { $track.properties.encoding } else { "Unknown encoding" }
            $forcedTrack = if ($track.properties.forced_track) { "Yes" } else { "No" }

            Write-Host "Enabled Track: $enabledTrack" -ForegroundColor Yellow
            Write-Host "Default Track: $defaultTrack" -ForegroundColor Yellow
            Write-Host "Encoding: $encoding" -ForegroundColor Yellow
            Write-Host "Forced Track: $forcedTrack" -ForegroundColor Yellow
        }

        Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }

    # Prepare --subtitle-tracks argument based on user input
    $subtitleTracksArg = ""
    $validIds = $trackInfo.tracks | Where-Object { $_.type -eq "subtitles" } | ForEach-Object { $_.id }

    # Use the function to ensure valid input (or skip if value already set at beginning of script)
    if ($subtitleTrackIds -eq "skip") {
        Write-Host "WARNING: Subtitle selection has been skipped per user request..." -ForegroundColor Red
        Start-Sleep 1
        Write-Host "Keeping all subtitle tracks..." -ForegroundColor Yellow
    } else {
        $subtitleTrackIds = Get-ValidSubtitleTrackIds -ValidIds $validIds        
    
        Write-Host ""

        switch ($subtitleTrackIds) {
            "all" {
                # Keep all subtitle tracks; no need to add --subtitle-tracks argument
                Write-Host "Keeping all subtitle tracks..." -ForegroundColor Green
            }
            "none" {
                # Exclude all subtitle tracks
                $subtitleTracksArg = "--no-subtitles"
                Write-Host "Excluding all subtitle tracks..." -ForegroundColor Green
            }
            default {
                # Include specified subtitle tracks
                $subtitleTracksArg = "--subtitle-tracks"
                Write-Host "Keeping subtitle track(s): $subtitleTrackIds" -ForegroundColor Green
            }
        }

    }

    Start-Sleep -Seconds 2
    Write-Host ""

    # Build mkvmerge command to modify the video track name and language
    $videoTrackId = ($trackInfo.tracks | Where-Object { $_.type -eq "video" }).id
    if ($null -ne $videoTrackId) {
        try {
            # Prepare mkvmerge arguments array
            $mkvmergeArgs = @(
                "--output", "`"$tempFile`""
                "--track-name", "${videoTrackId}:$releaseGroup"
                "--language", "${videoTrackId}:$videoLanguageCode"
                "--no-attachments", "--no-global-tags"
            )

            # Include audio track rename argument
            if (-not [string]::IsNullOrWhiteSpace($audioTrackRenameArg)) {
                $mkvmergeArgs += "--track-name"
                $mkvmergeArgs += "`"$audioTrackRenameArg`""
            }

            # Add --subtitle-tracks argument if needed
            if ($subtitleTracksArg) {
                if ($subtitleTrackIds -eq "none") {
                    $mkvmergeArgs += $subtitleTracksArg
                } else {
                    $mkvmergeArgs += $subtitleTracksArg
                    $mkvmergeArgs += $subtitleTrackIds  # Add subtitle track IDs as a separate argument
                }
            }

            # Add --title argument if specified
            if ($null -ne $fileTitle) {
                $mkvmergeArgs += "--title"
                $mkvmergeArgs += "`"" + $fileTitle + "`""
            }

            # Add the input file path
            $mkvmergeArgs += "`"$inputFile`""

            # DEBUGGING ARGS LIST
            #Write-Host "$mkvmergeArgs" -ForegroundColor Red
            #Write-Host ""
            #Read-Host

            # Execute the command
            & "$mkvmergePath" @mkvmergeArgs
            Write-Host ""
            Write-Host "Modified video track name to '$releaseGroup' and language to '$videoLanguage'." -ForegroundColor Yellow
        } catch {
            Write-Host ""
            Write-Host "Error modifying video track: $_" -ForegroundColor Red
        }
    } else {
        Write-Host ""
        Write-Host "No video track found to modify." -ForegroundColor Red
    }

    Write-Host ""

    # Move modified file to the output path
    if (Test-Path -LiteralPath $tempFile) {
        $finalOutputFile = [System.IO.Path]::Combine($outputPath, "$($file.BaseName).mkv")

        # Check if the final output file already exists
        if (Test-Path -LiteralPath $finalOutputFile) {
            Write-Host "File already exists: $finalOutputFile" -ForegroundColor Red
            Write-Host ""

            # Use a simple prompt for the user's choice
            $file_choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $file_choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Overwrite', 'Choose this option to overwrite the existing file.'))
            $file_choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Skip', 'Choose this option to skip processing the file.'))
            $file_choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Modify', 'Choose this option to modify the filename, enabling coexistence with existing files.'))

            # Prompt user for choice without displaying choices again
            $file_decision = $Host.UI.PromptForChoice('', '', $file_choices, 2)  # Empty strings for title and question in PromptForChoice

            Write-Host ""

            switch ($file_decision) {
                0 {
                    Write-Host "The file will be overwritten." -ForegroundColor Yellow
                    Write-Host ""
                    Start-Sleep 1
                }
                1 {
                    Write-Host "Processing of the file has been skipped." -ForegroundColor Yellow
                    Write-Host ""
                    Start-Sleep 1
                    continue
                }
                default {
                    Write-Host "The filename will be modified to enable coexistence." -ForegroundColor Yellow
                    Start-Sleep 1
                    
                    $counter = 1
                    do {
                        $modifiedFileName = "$($file.BaseName)_$counter.mkv"
                        $finalOutputFile = [System.IO.Path]::Combine($outputPath, $modifiedFileName)
                        $counter++
                    }
                    while (Test-Path -LiteralPath $finalOutputFile)
                    Write-Host ""
                    Write-Host "Saving as new file: $modifiedFileName" -ForegroundColor Yellow
                    Write-Host ""
                }                
            }
            Start-Sleep 2
        }

        Move-Item -Path $tempFile -Destination $finalOutputFile -Force
        Write-Host "Modified file saved as: $finalOutputFile" -ForegroundColor Green
    } else {
        Write-Host "No modified file found to move." -ForegroundColor Red
    }
    Start-Sleep -Seconds 2
    Write-Host ""
    Write-Host "END OF PROCESS -------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please wait..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    Write-Host "The system is checking for additional files in the queue. If any are available, processing will begin shortly..." -ForegroundColor Red
    Start-Sleep -Seconds 6
    Write-Host ""
    Write-Host "Clearing terminal..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    Clear-Host
}