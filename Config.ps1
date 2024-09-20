# Config file for hastables

# Language codes for ISO conversion
$languageCodes = @{}
[Globalization.CultureInfo]::GetCultures([Globalization.CultureTypes]::SpecificCultures) | ForEach-Object {
    $name = $_.EnglishName -replace '\(.*\)'
    $languageCodes[$name.Trim()] = $_.ThreeLetterISOLanguageName
}

# List of all codecs to rename audio track to (Add more codec here to rename audio files to)
$codecNames = @{
    'AC-3' = 'Dolby Digital'
    'E-AC-3' = 'Dolby Digital Plus'
    'MLP FBA' = 'TrueHD'
    'MLP FBA 16-ch' = 'TrueHD Atmos'
}