#!/bin/bash
TICKER_FILE="$HOME/.stock_tickers"

# Load tickers or initialize with defaults
if [ -f "$TICKER_FILE" ]; then
    mapfile -t TICKERS < "$TICKER_FILE"
    # Clean empty lines on load
    TICKERS=($(printf "%s\n" "${TICKERS[@]}" | grep -v '^$'))
else
    TICKERS=("AAPL" "MSFT")
    mkdir -p "$(dirname "$TICKER_FILE")"
    printf "%s\n" "${TICKERS[@]}" > "$TICKER_FILE"
fi

get_stock_price() {
    local ticker=$1
    local url="https://query1.finance.yahoo.com/v8/finance/chart/$ticker"
    local response=$(curl -s -A "Mozilla/5.0" "$url")
    local price=$(echo "$response" | jq -r '.chart.result[0].meta.regularMarketPrice // empty')
    local currency=$(echo "$response" | jq -r '.chart.result[0].meta.currency // "USD"')
    if [ -z "$price" ] || [ "$price" == "null" ]; then
        printf "%-10s: Price not available\n" "$ticker"
    else
        # Replace dot with comma for German locale
        price=$(echo "$price" | sed 's/\./,/g')
        printf "%-10s: %8s %s\n" "$ticker" "$price" "$currency"
    fi
}

add_ticker() {
    for new_ticker in "$@"; do
        new_ticker=$(echo "$new_ticker" | tr '[:lower:]' '[:upper:]')
        if ! printf '%s\n' "${TICKERS[@]}" | grep -q "^$new_ticker$"; then
            TICKERS+=("$new_ticker")
            echo "Added ticker '$new_ticker'."
        else
            echo "Ticker '$new_ticker' is already in the list." >&2
        fi
    done
}

remove_ticker() {
    for old_ticker in "$@"; do
        old_ticker=$(echo "$old_ticker" | tr '[:lower:]' '[:upper:]')
        TICKERS=($(printf "%s\n" "${TICKERS[@]}" | grep -v "^$old_ticker$"))
        echo "Removed ticker '$old_ticker'."
    done
}

show_ticker() {
    echo "Listing all Tickers:"
    for ticker in "${TICKERS[@]}"; do
        echo "  $ticker"
    done
}

show_help() {
    echo "Usage: $0 [OPTIONS] [TICKERS...]"
    echo "Options:"
    echo "  -a TICKER...    Add one or more tickers (uppercase or lowercase)"
    echo "  -r TICKER...    Remove one or more tickers (uppercase or lowercase)"
    echo "  -m TICKER       Manually query a ticker (without saving)"
    echo "  -l              List all saved tickers"
    echo "  -h              Show this help"
    echo "Examples:"
    echo "  $0                  Show prices of all saved tickers"
    echo "  $0 -a avgo tsla     Add AVGO and TSLA to the list"
    echo "  $0 -r aapl msft     Remove AAPL and MSFT from the list"
    echo "  $0 -r aapl -a ibm   Remove AAPL and add IBM in one command"
}

# Arrays to accumulate tickers to add/remove
to_add=()
to_remove=()
manual_query=""
show_prices=1

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a)
            show_prices=0
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                to_add+=("$1")
                shift
            done
            ;;
        -r)
            show_prices=0
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                to_remove+=("$1")
                shift
            done
            ;;
        -m)
            show_prices=0
            manual_query="$2"
            shift 2
            ;;
        -l)
            show_ticker
            exit 0
            ;;
        -h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Apply additions/removals
if [ ${#to_remove[@]} -gt 0 ]; then
    remove_ticker "${to_remove[@]}"
fi
if [ ${#to_add[@]} -gt 0 ]; then
    add_ticker "${to_add[@]}"
fi

# Clean empty lines
TICKERS=($(printf "%s\n" "${TICKERS[@]}" | grep -v '^$'))

# Save changes after all operations
printf "%s\n" "${TICKERS[@]}" > "$TICKER_FILE"

# Show prices if no other action was requested
if [ "$show_prices" -eq 1 ]; then
    echo "Current Stock Prices:"
    echo "------------------------"
    for ticker in "${TICKERS[@]}"; do
        get_stock_price "$ticker"
    done
fi

# Manual query
if [ -n "$manual_query" ]; then
    get_stock_price "$manual_query"
fi
