#!/bin/bash

# Print ASCII art in red color
echo -e "\033[31m" # Set text color to red


echo "Combined Output: A T I N                      _____        ________     ____       ____     _____        _____  "
echo "    █████╗   ████████╗  ██╗  ███╗   ██╗ ██   / ____\      (___  ___)   / __ \     / __ \   (_   _)      / ____\ "
echo "   ██╔══██╗  ╚══██╔══╝  ██║  ████╗  ██║ ██  ( (___            ) )     / /  \ \   / /  \ \    | |       ( (___   "
echo "   ███████║     ██║     ██║  ██╔██╗ ██║      \___ \          ( (     ( ()  () ) ( ()  () )   | |        \___ \  "
echo "   ██╔══██║     ██║     ██║  ██║╚██╗██║          ) )          ) )    ( ()  () ) ( ()  () )   | |   __       ) ) "
echo "   ██║  ██║     ██║     ██║  ██║ ╚████║      ___/ /          ( (      \ \__/ /   \ \__/ /  __| |___) )  ___/ /  "
echo "   ╚═╝  ╚═╝     ╚═╝     ╚═╝  ╚═╝  ╚═══╝     /____/           /__\      \____/     \____/   \________/  /____/   "


echo -e "\033[0m" # Reset text color


# Check if Python is installed
if ! command -v python3 &> /dev/null
then
    echo "Python3 is not installed. Please install it before proceeding."
    exit 1
fi

# Check if Selenium is installed in Python
if ! python3 -c "import selenium" &> /dev/null
then
    echo "Selenium Python module is not installed. Installing Selenium..."
    pip3 install selenium
    if [ $? -ne 0 ]; then
        echo "Failed to install Selenium. Please install manually."
        exit 1
    fi
fi

# Check if ChromeDriver exists in /usr/bin/
CHROMEDRIVER_PATH="/usr/bin/chromedriver"
if [ ! -f "$CHROMEDRIVER_PATH" ]; then
    sudo ./chrome-driver.sh
fi

# Define the XSS payloads list (or read from a file)
payloads_file="payloads.txt"

# Function to escape special characters
escape_special_chars() {
    local input="$1"
    echo "$input" | sed 's/[&]/\\&/g'
}

# Function to scan for reflected payloads
scan_url_for_reflection() {
    local url=$1
    local payload=$2

    # Escape special characters in the payload
    escaped_payload=$(escape_special_chars "$payload")

    modified_url="${url//Payload_URL/$escaped_payload}"
    # Perform the curl request
    response=$(curl -s "$modified_url")

    python3 fireblaster-xss.py "$modified_url"
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <full_url>"
    exit 1
fi

full_url="$1"

# Check if the payloads file exists
if [ ! -f "$payloads_file" ]; then
    echo "Payloads file not found: $payloads_file"
    exit 1
fi

# Read each payload from the file and scan one at a time
while IFS= read -r payload; do
    #echo "Testing payload: $payload"
    scan_url_for_reflection "$full_url" "$payload"
done < "$payloads_file"

echo "Finished testing all payloads."

