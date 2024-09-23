# MKV Processor

This PowerShell script automates the processing of `.mkv` files using MKVToolNix's `mkvmerge`. It enables users to modify video and audio track names, set languages, manage subtitle tracks, and handle batch processing of multiple files. The script ensures flexibility and control by allowing users to either skip or customize specific steps, such as subtitle selection and file title renaming.

![License](https://img.shields.io/github/license/RegEdits-TSC/MKV-Processor) ![Issues](https://img.shields.io/github/issues/RegEdits-TSC/MKV-Processor) ![Stars](https://img.shields.io/github/stars/RegEdits-TSC/MKV-Processor) ![Forks](https://img.shields.io/github/forks/RegEdits-TSC/MKV-Processor)

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Error Handling](#error-handling)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Video/Audio Track Renaming**: Users can rename video and audio tracks based on user input.
- **Language Management**: Users can assign or modify the language of video and audio tracks.
- **Subtitle Management**: 
  - Keep all subtitles
  - Remove all subtitles
  - Select specific subtitle tracks to retain
- **File Title Customization**: Option to rename the file title or retain the default title.
- **Batch Processing**: Process multiple `.mkv` files at once.
- **Input/Output Path Control**: Set directories for source files and output locations.
- **Error Handling & Validation**: Ensures smooth operation with user feedback on invalid inputs or errors.

## Prerequisites

Ensure you have the following:

- **MKVToolNix**: Download and install from [here](https://mkvtoolnix.download/).
- **PowerShell 5.1**: This script is designed to work in environments where PowerShell 5.1 is available (Windows).

Make sure that the `mkvmerge` executable path is correctly configured in the script.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/RegEdits-TSC/MKV-Processor.git
   ```

2. Navigate to the project directory:
   
   ```bash
   cd MKV-Processor
   ```

4. Install MKVToolNix if not already installed:
   - [Windows](https://mkvtoolnix.download/)
   - [Linux/macOS](https://mkvtoolnix.download/downloads.html)
  
## Usage

The script iterates through all `.mkv` files within the specified input directory, processes each file according to the provided parameters, and saves the modified files to the designated output directory.

1. Navigate to the project directory:
   
   ```bash
   cd MKV-Processor
   ```

3. Exectute the command in a PowerShell window:
> [!NOTE]
> The `InputPath`, `OutputPath`, and `mkvmerge` executable path can be modified by editing the `MKV Tools` PowerShell script. However, please make these changes at your own risk, as I will not provide support for any modifications you make within this file. To ensure proper functionality, please refer to the example below for setting the paths correctly.

  ```bash
  & './MKV Tools.ps1' -InputPath "path/to/input/file(s)" -OutputPath "path/to/output/file(s)" -mkvmergePath "C:\Program Files\MKVToolNix\mkvmerge.exe"
  ```

## Configuration

Configuration options such as paths and default values for languages, track names, etc., can be set using the script parameters or modified in the script itself.

Example parameters:

```
[string]$inputPath = "D:\Movies & Show Sorting\Sort"
[string]$outputPath = "D:\Movies & Show Sorting\Sorted"
[string]$mkvmergePath = "C:\Program Files\MKVToolNix\mkvmerge.exe"
```

## Error Handling

The script includes error handling and validation to ensure smooth processing:

- Ensures valid paths for input/output.
- Validates user input for file titles, release groups, and track IDs.
- Provides feedback when files are skipped or overwritten.

## Roadmap

- **v1.1.0**:
  - Improve error handling with more detailed log outputs.
  - Add support for more advanced track editing (e.g., track ordering).
  - Provide customization options for metadata tags and other MKV properties.
  
- **Future**:
  - Integration with external APIs for automatic metadata retrieval (e.g., movie databases).
  - Apply and assign a title to each file based on its filename during the processing stage.

## Contributing

Contributions are welcome! Here's how you can contribute:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
