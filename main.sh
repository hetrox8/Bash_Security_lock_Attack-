#!/bin/bash

# Configuration parameters
password_lists_dir="password_lists"  # Directory containing password lists
num_threads=4  # Number of parallel threads for password attempts
max_attempts_per_password=3  # Maximum attempts per password before adjusting strategy
initial_retry_delay=5  # Initial delay between retry attempts (in seconds)
retry_backoff_factor=2  # Backoff factor for increasing delay after each failed attempt
max_retry_delay=60  # Maximum delay between retry attempts (in seconds)
log_file="bruteforce.log"  # Log file path

# Function to log messages to a file
log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$log_file"
}

# Function to attempt passwords in parallel with smart retry mechanism
attempt_passwords() {
    local retry_delay=$initial_retry_delay
    while IFS= read -r password; do
        local attempts=0
        while (( attempts < max_attempts_per_password )); do
            echo "Attempting password: $password"
            # Insert command to attempt password here (e.g., login attempt)
            sleep "$retry_delay"  # Pause between attempts

            # Check if password attempt is successful
            if [ successful_password_attempt ]; then
                log_message "Password successfully found: $password"
                return 0  # Exit function with success status
            else
                (( attempts++ ))
                log_message "Password attempt $attempts failed for password: $password"
                (( retry_delay = retry_delay * retry_backoff_factor ))  # Increase retry delay
                retry_delay=$(( retry_delay > max_retry_delay ? max_retry_delay : retry_delay ))  # Limit max retry delay
            fi
        done
    done < "$1"
}

# Main function
main() {
    # Initialize log file
    echo "Brute-force attack started at $(date)" > "$log_file"
    echo "-------------------------------------" >> "$log_file"

    # Iterate over password lists
    for file in "$password_lists_dir"/*.txt; do
        # Check if file exists and is readable
        if [ -r "$file" ]; then
            # Run password attempts in parallel
            parallel -j"$num_threads" attempt_passwords "$file"
        else
            log_message "Error: Password list file $file not found or not readable."
        fi
    done

    # Log completion message
    log_message "Brute-force attack completed at $(date)"
}

# Execute main function and handle errors gracefully
if ! main; then
    log_message "Error: Brute-force attack encountered an error and terminated."
fi
