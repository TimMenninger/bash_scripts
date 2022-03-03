BEGIN {
    # Define colors
    # The ifs here allow the color codes to be overridden on the command line
    if (!CLR_CLEAR)  CLR_CLEAR="\033[0m";
    if (!CLR_ERR)    CLR_ERR="\033[1m\033[91m";
    if (!CLR_WARN)   CLR_WARN="\033[1m\033[93m";
    if (!CLR_GOOD)   CLR_GOOD="\033[1m\033[92m";
    if (!CLR_MISC)   CLR_MISC="\033[1m\033[94m";
    if (!CLR_OUTPUT) CLR_OUTPUT="\033[1m\033[95m";
    # Default to printing everythin to stdout and not having a separate error
    # file
    if (!FULL_OUTPUT_FILE) FULL_OUTPUT_FILE="/dev/stdout";
    if (!ERROR_OUTPUT_FILE) ERROR_OUTPUT_FILE="/dev/null";
    currentState = 0;
    diags = "";
    totwarn = 0;
    toterr = 0;
}
# These blocks of code run once for each line of output from gbuild
# Use a small state machine to parse gbuild output
{
    if (currentState == 0) {
        # Initial state, this is output directly from gbuild

        # Check for and colorize any warning or error lines
        haswarn  =sub(/^[\S]+:[0-9]+[0-9]+: warning[^:]*:/, CLR_WARN "&" CLR_CLEAR);
        haserr   =sub(/^[\S]+:[0-9]+[0-9]+: (fatal )?error[^:]*:/  , CLR_ERR "&" CLR_CLEAR);
        # Colorize other miscelaneous output
        sub(/^Done/, CLR_GOOD "&" CLR_CLEAR);
        sub(/^Build target '[^']*' failed/, CLR_ERR "&" CLR_CLEAR);
        sub(/^Error:.*/, CLR_ERR "&" CLR_CLEAR);
        sub(/^Building .*/, CLR_MISC "&" CLR_CLEAR);
        sub(/^Cleaning .*/, CLR_MISC "&" CLR_CLEAR);

        if (haswarn > 0 || haserr > 0) {
            # This is the first line of a compiler diagnostic (warning/error)
            # Bump the appropriate counter
            totwarn += haswarn;
            toterr  += haserr;
            # Store this line of the diagnostic, and switch to the state for saving diagnostic output
            diags = diags $0 "\n";
            currentState = 1;
            # Grab a short version of the diagnostic (file, line, diag number) and print it
            match($0, /^.*(warning|error)[^:]*/, diagRegion);
            if (INCREMENTAL_ERRORS) {
                print $0 > FULL_OUTPUT_FILE;
            } else {
                print diagRegion[0] CLR_CLEAR > FULL_OUTPUT_FILE;
            }
            print ERROR_OUTPUT_PREFIX " " $0 > ERROR_OUTPUT_FILE;
        } else {
            # Standard gbuild output
            print > FULL_OUTPUT_FILE;
        }
    } else if (currentState == 1) {
        # Currently in the detailed message for a warning/error. Save the contents to print at the end
        if ($0 == "") {
            # Detailed messages are terminated by a blank line. Switch back to the default state.
            currentState = 0;
        } else {
            # Store the line of diagnostic output
            diags = diags $0 "\n";
            print ERROR_OUTPUT_PREFIX " " $0 > ERROR_OUTPUT_FILE
            if (INCREMENTAL_ERRORS) print $0 > FULL_OUTPUT_FILE
        }
    } else if (currentState == 2) {
        # Linker error, this line is another line of error, then return to normal after
        diags = diags $0 "\n";
        print ERROR_OUTPUT_PREFIX " " $0 > ERROR_OUTPUT_FILE
        if (INCREMENTAL_ERRORS) print $0 > FULL_OUTPUT_FILE
        currentState = 0;
    }
}
END {
    # Print a final build summary if any warnings/errors occurred
    if (totwarn > 0 || toterr > 0) {
        print CLR_MISC "======== WARNINGS/ERRORS ========" CLR_CLEAR > FULL_OUTPUT_FILE;
        print diags > FULL_OUTPUT_FILE;
        if (LOG_FILE) {
            if (COLORIZE_LOG_FILE) {
                print diags > LOG_FILE;
            } else {
                nocolor_diags = diags
                gsub(/\033\[[0-9]+m/, "", nocolor_diags);
                print nocolor_diags > LOG_FILE;
            }
        }
    }
    if (totwarn > 0) {
        print CLR_WARN "Total warnings: " CLR_CLEAR totwarn > FULL_OUTPUT_FILE;
        print ERROR_OUTPUT_PREFIX " " CLR_WARN "Total warnings: " CLR_CLEAR totwarn > ERROR_OUTPUT_FILE;
    }
    if (toterr  > 0) {
        print CLR_ERR  "Total errors: "   CLR_CLEAR toterr > FULL_OUTPUT_FILE;
        print ERROR_OUTPUT_PREFIX " " CLR_ERR  "Total errors: "   CLR_CLEAR toterr > ERROR_OUTPUT_FILE;
    }
}
