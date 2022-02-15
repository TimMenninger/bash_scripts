#!/usr/bin/python
import csv, sys, argparse, string

# ARGUMENT PARSING
parser = argparse.ArgumentParser(description="Convert CSV to ASCII table", prog=sys.argv[0])
parser.add_argument("csv", type=str, metavar="csv_file", nargs="+", help="The CSV file to convert")
parser.add_argument("-w", "--width", type=int, default=80, help="Width of the table")
parser.add_argument("--no_wrap", const=True, nargs="?", default=False)

data = None
args = None
col_widths = None

def compute_widths():
    global data, col_widths

    # Read the CSV into an array
    with open(args.csv) as csvfile:
        data = list(csv.reader(csvfile))

    # How many columns are there, so we can make space for borders
    n_cols = len(data[0])

    # Remaining width for characters is number of columns times 3 (one for a
    # space on each side and the border), plus 1 for the rightmost border
    rem_wid = args.width - 3*n_cols - 1

    # Maximum width of each column if it were no wrapping.  Minimum width is the
    # largest word in the line
    max_widths = [ len(i) for i in data[0] ]
    col_widths = [ 0 for i in data[0] ]
    for row in data:
        for i in range(len(row)):
            max_widths[i] = max(len(row[i]), max_widths[i])
            for word in row[i].split():
                col_widths[i] = max(len(word), col_widths[i])
    rem_wid -= sum(col_widths)
    if (sum(col_widths) > rem_wid):
        args.width += (sum(col_widths) - rem_wid)

    # Dole out the rest based on proportion of maximum width.  If there isn't
    # enough space, we will have to print more than we were instructed to
    added_width = 0
    width_diffs = [ max_widths[i] - col_widths[i] for i in range(len(col_widths)) ]
    width_diff_sum = sum(width_diffs)
    total_added = 0
    for i, width in enumerate(width_diffs):
        to_add = (rem_wid * width) // width_diff_sum
        col_widths[i] += to_add
        total_added += to_add
    rem_wid -= total_added

    # Give the remaining width to the column that is farthest from its maximum
    # width one at a time (in case after giving one, another one is the new
    # closest).  Don't exceed the max width.  If all are at max width, no need
    # to make table larger yet
    while rem_wid > 0:
        max_idx = -1
        max_distance = -1
        for i, max_wid in enumerate(max_widths):
            if col_widths[i] < max_widths[i]:
                if max_idx < 0 or max_wid - col_widths[i] > max_distance:
                    max_idx = i
                    max_distance = col_widths[i] - max_wid
        if max_idx == -1:
            break
        col_widths[max_idx] += 1
        rem_wid -= 1

    # If there are remaining widths, then give them to the smallest columns
    # until we run out
    while rem_wid > 0:
        min_idx = 0
        min_wid = col_widths[0]
        for i, wid in enumerate(col_widths):
            if wid < min_wid:
                min_idx = i
        col_widths[min_idx] += 1
        rem_wid -= 1

def break_lines():
    global data

    # So we can remove ugly characters
    printable = set(string.printable)

    # Separate each line at a space so it all fits
    for y, row in enumerate(data):
        for x, col in enumerate(row):
            line_to_break = col
            data[y][x] = []
            curr_line = ""
            for raw_word in col.split():
                # Take off ugly characters
                word = filter(lambda x: x in printable, raw_word)

                # Put a space unless it was the first word
                if len(curr_line) > 0:
                    curr_line += " "

                # Put the next word
                if len(curr_line) > 0 and len(curr_line) + len(word) + 1 > col_widths[x]:
                    data[y][x].append(curr_line)
                    curr_line = word
                else:
                    if len(curr_line) > 0:
                        curr_line += " "
                    curr_line += word
            data[y][x].append(curr_line)

    # Make all cells in each row the same height
    for y, row in enumerate(data):
        max_height = len(row[0])

        # Get the max height
        for col in row:
            if len(col) > max_height:
                max_height = len(col)

        # Make each item the same height
        for x, col in enumerate(row):
            for i in range(len(col), max_height):
                data[y][x].append("")

def horizontal_line():
    line = "+"
    for width in col_widths:
        line += (2 + width) * "-"
        line += "+"
    return line + "\n"

def print_table():
    lines = [ horizontal_line() ]
    for row in data:
        for j in range(len(row[0])):
            lines.append("|")
            for i, col in enumerate(row):
                # Padding so each cell in a column is the same.  Add one for the
                # intrinsic padding.  The other one goes before so we don't include
                # it
                pad_len = 1 + col_widths[i] - len(col[j])
                lines[-1] += " %s%s|" %(col[j], pad_len*" ")
            lines[-1] += "\n"
        lines.append(horizontal_line())
    print("".join(lines))

if __name__ == "__main__":
    # Parse arguments
    args = parser.parse_args(sys.argv)
    if len(args.csv) != 2:
        parser.print_help()
        exit(1)
    args.csv = args.csv[1]

    # Compute widths of columns
    compute_widths()

    # Break items into lines
    break_lines()

    # Print the table
    print_table()

