# Stock Ticker CLI

This is a simple Bash script to fetch and display stock prices for your favorite tickers. It saves your tickers to a file in your home directory, so you don’t have to re-enter them every time.

---

## Features
- Add or remove multiple stock tickers at once.
- Fetch and display current stock prices in a neat, aligned format.
- Supports manual queries for one-off checks.
- Persists your ticker list between runs.

---

## Requirements
- `bash`
- `curl`
- `jq` (for parsing JSON responses)

Install `jq` with:
```bash
sudo apt install jq  # Debian/Ubuntu
```

---

## Usage

### Basic Commands
| Command                          | Description                                      |
|----------------------------------|--------------------------------------------------|
| `bash stocks.sh`                 | Show prices for all saved tickers.               |
| `bash stocks.sh -a AAPL MSFT`    | Add one or more tickers.                         |
| `bash stocks.sh -r AAPL MSFT`    | Remove one or more tickers.                      |
| `bash stocks.sh -m AAPL`         | Manually query a ticker (does not save it).      |
| `bash stocks.sh -l`              | List all saved tickers.                          |
| `bash stocks.sh -h`              | Show help.                                       |

### Examples
```bash
# Add and remove tickers in one command
bash stocks.sh -r AAPL MSFT -a IBM ING UBK.DE

# Show prices for all saved tickers
bash stocks.sh

# Manually query a ticker
bash stocks.sh -m TSLA
```

---

## Notes
- Tickers are saved in `~/.stock_tickers`.
- Prices are displayed in your local number format (e.g., `266,40 €`).
- The script uses Yahoo Finance as its data source.

---
**Enjoy tracking your stocks from the command line!** Let me know if you have questions or suggestions.