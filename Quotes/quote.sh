#!/bin/bash

# quote.sh
# A simple quote script that displays a random quote in the terminal.
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issues: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Requests: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# COLORS
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# FUNCTIONS
show_help() {
    echo -e "${BOLD}${BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│           QUOTE HELP              │"
    echo "└───────────────────────────────────┘"
    echo ""
    echo -e "${CYAN}${BOLD}Options:${RESET}"
    echo -e "  ${YELLOW}-h${RESET}    ${GREEN}Show this help message${RESET}"
    echo -e "  ${YELLOW}-n${RESET}    ${GREEN}Show quote as a desktop notification${RESET}"
    echo ""
    echo -e "${BLUE}This script displays a random quote in the terminal.${RESET}"
    echo ""
    exit 0
}

# PARSE ARGUMENTS
show_notification=false

while getopts "hn" opt; do
    case $opt in
        h)
            show_help
            ;;
        n)
            show_notification=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            ;;
    esac
done

# QUOTES
quotes=(
    "\"Simplicity is the soul of efficiency.\" — Austin Freeman"
    "\"It works on my machine.\" — Every developer ever"
    "\"A clean system is a happy system.\""
    "\"First, solve the problem. Then, write the code.\" — John Johnson"
    "\"Programming isn't about what you know; it's about what you can figure out.\" — Chris Pine"
    "\"The best error message is the one that never shows up.\" — Thomas Fuchs"
    "\"Talk is cheap. Show me the code.\" — Linus Torvalds"
    "\"Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live.\" — John Woods"
    "Command Tip: 'CTRL+L' clears the terminal screen faster than typing 'clear'"
    "\"Sometimes it pays to stay in bed on Monday, rather than spending the rest of the week debugging Monday's code.\" — Dan Salomon"
    "\"Programming is an art of telling another human what one wants the computer to do.\" — Donald Knuth"
    "\"God said, 'let there be light,' and there was light.\" — Terry A. Davis"
    "\"I am an artist. This is my art.\" — Terry A. Davis"
    "\"Hardware eventually fails. Software eventually works.\" — Michael Hartung"
    "Command Tip: 'history | grep command' to find that command you used a while ago"
    "\"Another day, another line of code.\" — fr0st"
    "\"Software is like sex: it's better when it's free.\" — Linus Torvalds"
    "\"Most good programmers do programming not because they expect to get paid or get adulation by the public, but because it is fun to program.\" — Linus Torvalds"
    "\"Code is like humor. When you have to explain it, it's bad.\" — Cory House"
    "\"Java is to JavaScript what car is to carpet.\" — Chris Heilmann"
    "\"The best way to predict the future is to invent it.\" — Alan Kay"
    "\"Computers are good at following instructions, but not at reading your mind.\" — Donald Knuth"
    "\"The most disastrous thing that you can ever learn is your first programming language.\" — Alan Kay"
    "\"Your most unhappy customers are your greatest source of learning.\" — Bill Gates"
)

random_index=$((RANDOM % ${#quotes[@]}))
selected_quote="${quotes[$random_index]}"

if [[ "$selected_quote" == Command* ]]; then
    TIP_COLOR=$YELLOW
    EMOJI="⚡"
else
    TIP_COLOR=$CYAN
    EMOJI="💭"
fi

# Display the quote in terminal
if ! $show_notification; then
    echo ""
    echo -e "${PURPLE}${BOLD}       <<< QUOTE OF THE DAY >>>   ${RESET}"
    echo -e "${GREEN}──────────────────────────────────────${RESET}"
    echo ""
    echo -e "${TIP_COLOR}$EMOJI ${selected_quote}${RESET}"
    echo ""
fi

# Send notification if requested
if $show_notification; then
    # Remove color codes for notification
    clean_quote="${selected_quote}"
    if command -v notify-send &> /dev/null; then
        # Set notification to stay for 7 seconds with -t option (time in milliseconds)
        notify-send -t 7000 "Quote of the Day" "$EMOJI $clean_quote"
    else
        echo "Error: notify-send command not found. Please install libnotify-bin package."
        exit 1
    fi
fi
