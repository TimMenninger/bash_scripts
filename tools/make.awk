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
    currentState = 0;
    diags = "";
    notes = "";
    totwarn = 0;
    toterr = 0;
    totfail = 0;
    totnotes = 0;
}
# These blocks of code run once for each line of output from gbuild
# Use a small state machine to parse gbuild output
{
    nextState = currentState == 0 ? 0 : currentState-1;
    if (currentState == 0) {
        # Initial state, this is output directly from gbuild

        # Check for and colorize any warning or error lines
        haswarn  =sub(/^\S+:[0-9]+:([0-9]+:)? warning[^:]*:/, CLR_WARN "&" CLR_CLEAR);
        haserr   =sub(/^\S+:[0-9]+:([0-9]+:)? error[^:]*:/, CLR_ERR "&" CLR_CLEAR);
        hasfail  =sub(/^\S*Makefile:[0-9]+: recipe for target '[^']+' failed/, CLR_ERR "&" CLR_CLEAR);

        # Random sometimes-important outputs from make
        hasmake  =sub(/^make\[[0-9]+\]: /, CLR_OUTPUT "&" CLR_CLEAR);

        if (haswarn > 0 || haserr > 0 || hasfail > 0) {
            # This is the first line of a compiler diagnostic (warning/error)
            # Bump the appropriate counter
            totwarn += haswarn;
            toterr  += haserr;
            totfail += hasfail;
            # Store this line of the diagnostic, and switch to the state for saving diagnostic output
            diags = diags $0 "\n";

            ## # Grab a short version of the diagnostic (file, line, diag number) and print it
            ## match($0, /^.*(warning|error)[^:]*/, diagRegion);
            ## print $0 > FULL_OUTPUT_FILE;

            # One more line diagnostic for make error, two lines for compile,
            # none more for no make target. States numbered for how many more
            # lines of diagnostic
            if (hasfail > 0) {
                nextState = 1;
            } else if (haswarn > 0 || haserr > 0) {
                nextState = 2;
            }
        } else {
            # Always highlight "error" and "warning" and "fail" for visibility,
            # but only here if we didn't care enough to report it
            IGNORECASE = 1
            sub(/<warn(ing)?(:)?>/, CLR_WARN "&" CLR_CLEAR);
            sub(/<error(:)?>/, CLR_ERR "&" CLR_CLEAR);
            sub(/<fail(ure|ed)?(:)?>/, CLR_ERR "&" CLR_CLEAR);

            # Notes, will match some errors but are only considered if the line 
            # isn't otherwise determined to be a warning or error
            hasnote  =sub(/^\([^\*]*\*\*\*[^\*]*$/, "&");
            hasnote +=sub(/^\S*Makefile:[0-9]+: /, CLR_OUTPUT "&" CLR_CLEAR);
            if (hasnote > 0) {
                diags = diags $0 "\n";
                notes = notes $0 "\n";
            }
            totnotes += hasnote;
        }
    } else {
        isignored =sub(/^make\[[0-9]+\]:.*\(ignored\)$/, "&");
        if (isignored > 0) {
            totfail -= 1;
        }

        # Store the line of diagnostic output
        diags = diags $0 "\n";
    }

    print $0 > FULL_OUTPUT_FILE;
    currentState = nextState;
}
END {
    # Print a final build summary if any warnings/errors occurred
    if (totnotes > 0) {
        print CLR_MISC "\n\n============= NOTES =============" CLR_CLEAR > FULL_OUTPUT_FILE;
        print notes > FULL_OUTPUT_FILE;
    }

    if (totwarn > 0 || toterr > 0 || totfail > 0) {
        print CLR_MISC "\n\n======== WARNINGS/ERRORS ========" CLR_CLEAR > FULL_OUTPUT_FILE;
        print diags > FULL_OUTPUT_FILE;

        if (totwarn > 0) {
            print CLR_WARN "Total warnings: " CLR_CLEAR totwarn > FULL_OUTPUT_FILE;
        }
        if (toterr  > 0) {
            print CLR_ERR  "Total errors: "   CLR_CLEAR toterr > FULL_OUTPUT_FILE;
        }
    } 

    print CLR_MISC "\n\n=================================" CLR_CLEAR > FULL_OUTPUT_FILE;

    if (toterr > 0 || totfail > 0) {
        print CLR_ERR "Build Failed" CLR_CLEAR > FULL_OUTPUT_FILE;
    } else if (totwarn > 0) {
        print CLR_WARN "Build Succeeded with " totwarn " Warning(s)" CLR_CLEAR > FULL_OUTPUT_FILE
    } else {
        print CLR_GOOD "Build Succeeded" CLR_CLEAR > FULL_OUTPUT_FILE
    }
}
