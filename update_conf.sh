#!/bin/bash

# Function to validate input against allowed options
validate_input() {
    local input_value="$1"
    shift
    local valid_options=("$@")
    
    for option in "${valid_options[@]}"; do
        if [[ "$input_value" == "$option" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to read and validate user input
get_user_input() {
    local prompt="$1"
    shift
    local valid_options=("$@")

    while true; do
        read -p "$prompt: " user_input
        if validate_input "$user_input" "${valid_options[@]}"; then
            echo "$user_input"
            return
        else
            echo "Invalid input. Please enter one of the following: ${valid_options[*]}"
        fi
    done
}

# Get user inputs with validation
component_name=$(get_user_input "Enter Component Name [INGESTOR/JOINER/WRANGLER/VALIDATOR]" "INGESTOR" "JOINER" "WRANGLER" "VALIDATOR")
scale=$(get_user_input "Enter Scale [MID/HIGH/LOW]" "MID" "HIGH" "LOW")
view=$(get_user_input "Enter View [Auction/Bid]" "Auction" "Bid")
count=$(get_user_input "Enter Count [single digit number]" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

# Determine the view string
if [[ "$view" == "Auction" ]]; then
    view_str="vdopiasample"
else
    view_str="vdopiasample-bid"
fi

# Define the line to replace in the conf file
conf_file="sig.conf"
line_to_replace=".* ; .* ; .* ; ETL ; .*; "

# Create the new line to write to the config file
new_line="${view_str} ; ${scale} ; ${component_name} ; ETL ; vdopia-etl= ${count}"

# Update the configuration file
if [[ -f "$conf_file" ]]; then
    sed -i "s|.*;.*;.*;.*;.*|$new_line|" "$conf_file"
    echo "Updated $conf_file successfully."
else
    echo "Configuration file $conf_file does not exist."
fi
