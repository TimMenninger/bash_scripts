#!/bin/bash

################################################################################
#
# KNOWN PRINTER IPs AND NAMEs
#

NORTH_BUILDING_IP="192.168.102.97"
MAIN_BUILDING_DOWNSTAIRS_IP="192.67.158.128"

################################################################################

# Positional non-options arguments
POSITIONAL_ARGS=()

# Printer to print at
PRINTER=""

# Prints with line numbers
OPTIONS="-C -E"

function usage() {
    echo "$0 [-options] file..."
    echo "    Prints by default on landscape with two columns."
    echo ""
    echo "    options:"
    echo "        --help - Prints usage"
    echo "        -h =<name> - Specifies the name of the printer, or the IP"
    echo "        -ip <name> - Same as --host"
    echo "        --not-source-code - By default, this prints assuming it is"
    echo "            source code.  This argument thus removes line numbers and"
    echo "            disables highlighting source code."
    echo "        --ghs-north-building - Prints to the north building at GHS"
    echo "        --ghs-north - Prints to the north building at GHS"
    echo "        --ghs-lp1 - Prints to main building first floor in the"
    echo "          southwest hallway (closest to Chapala)"
    echo "        --ghs-main-building - Same as --ghs-lp1"
    echo "        --ghs-main-floor-1 - Same as --ghs-lp1"
    echo "        --ghs-main - Same as --ghs-lp1"
    echo ""
    echo "    file - The file to print.  This will print all listed files."
    echo ""
}

function parse_args() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in

        ########################################
        #
        # HELP - print usage
        #
        --help)
            usage $@
            exit 0
            ;;

        ########################################
        #
        # HOST / IP - specifie host name or IP
        #
        -h|-ip)
            shift # past argument
            PRINTER="$1"
            ;;

        ########################################
        #
        # SOURCE CODE OPTIONS
        #
        --not-source-code)
            OPTIONS=""
            ;;

        ########################################
        #
        # NORTH BUILDING
        #
        --ghs-north-building|--ghs-north)
            PRINTER=$NORTH_BUILDING_IP
            ;;

        ########################################
        #
        # MAIN BUILDING FIRST FLOOR
        #
        --ghs-main-building|--ghs-main|--ghs-main-floor-1|--ghs-lp1)
            PRINTER=$MAIN_BUILDING_DOWNSTAIRS_IP
            ;;

        ########################################
        #
        # KEEP THE ARGUMENT
        #
        *)
            POSITIONAL_ARGS+=("$key")
            ;;

        esac
        shift # past argument

    done

    # There should be only one argument
    if [[ ${#POSITIONAL_ARGS[@]} -eq 0 ]]; then
        usage
        exit
    fi
}

function print_files() {
    # Only care about positional arguments now
    set -- "${POSITIONAL_ARGS[@]}"

    # Print all files
    while [[ $# -gt 0 ]]; do
        FILE="$1"
        echo "$PRINTER $FILE"
        enscript $OPTIONS -G -2r --margins=20:20:15:15 --printer=$PRINTER $FILE
        shift # past argument to next file
    done
}

function main() {
    parse_args $@
    print_files $@
}

main $@

