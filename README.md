# JXBarcode

A lightweight desktop application for generating barcode images (QR codes) from user-inputted text. Built with Fyne — a cross-platform GUI toolkit for Go.

## Features
- Simple and intuitive interface
- Converts any text into a QR code
- Instant image rendering
- Native desktop experience with minimal dependencies

## Installation

### 1. Install Fyne dependencies
Follow the official Fyne setup guide: https://docs.fyne.io/started

For Ubuntu:
```bash
sudo apt install golang gcc libgl1-mesa-dev xorg-dev libxkbcommon-dev
```

### 2. Install Fyne CLI tools (optional)
If you want to package the app as an installable binary:
```bash
go install fyne.io/tools/cmd/fyne@latest
```

### 3. Make sure Go binaries are accessible
Add this to your `~/.bashrc` (or equivalent shell profile):
```bash
export PATH="$HOME/go/bin:$PATH"
```
Then refresh your shell:
```bash
source ~/.bashrc
```

### 4. Build the application
Clone the repository and build:
```bash
git clone https://github.com/duckzland/jxbarcode.git
cd jxbarcode
go build -o jxbarcode
```
This will:
- Download required Go modules
- Compile the app
- Produce the `jxbarcode` executable

## Usage
Launch the application:
```bash
./jxbarcode
```
Then:
- Enter text into the input field
- Click "Generate Barcode"
- A QR code image will be rendered

Use cases: wallet addresses, URLs, or any arbitrary text.

## Notes
- The app uses the QR code format, broadly compatible with crypto wallets and mobile scanners.
- No internet connection is required — generation is done locally.
- Tested on: Ubuntu, Windows 11, Android