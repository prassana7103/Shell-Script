#!/bin/bash

# Function to update the configuration file
update_conf_file() {
    local view=$1
    local scale=$2
    local component=$3
    local count=$4

    if [[ $view == "auction" ]]; then
        view="vdopiasample"
    else
        view="vdopiasample-bid"
    fi

    # Construct the configuration line with variable values
    local config_line="$view : $scale ; $component ; ETL ; vdopia-etl= $count"

    # Append the configuration line to the end of the file
    echo "$config_line" > sig.conf

    # Check if the echo command succeeded
    if [ $? -eq 0 ]; then
        echo "Conf line appended successfully."
    else
        echo "Error: Failed to append conf line."
        exit 1
    fi
}

# Main script starts here
while getopts ":c:s:v:n:" opt; do
    case ${opt} in
        c )
            component=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
            if ! [[ $component =~ ^(ingestor|joiner|wrangler|validator)$ ]]; then
                echo "Invalid component name. Please choose from INGESTOR, JOINER, WRANGLER, or VALIDATOR." >&2
                exit 1
            fi
            ;;
        s )
            scale=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
            if ! [[ $scale =~ ^(mid|high|low)$ ]]; then
                echo "Invalid scale. Please choose from MID, HIGH, or LOW." >&2
                exit 1
            fi
            ;;
        v )
            view=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
            if ! [[ $view =~ ^(auction|bid)$ ]]; then
                echo "Invalid view. Please choose from Auction or Bid." >&2
                exit 1
            fi
            ;;
        n )
            count=$OPTARG
            if ! [[ $count =~ ^[0-9]$ ]]; then
                echo "Invalid count. Please enter a single digit." >&2
                exit 1
            fi
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

update_conf_file "$view" "$scale" "$component" "$count"
echo "Conf file updated successfully."
