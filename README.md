# Paul Roche — CS 688 Final Project

Final project for **Web Analytics and Mining** (CS 688) at Boston University. The project performs **stock sentiment analysis** using Twitter data and R: collecting tweets about selected stocks, text mining, sentiment scoring, and visualization with word clouds and stock charts.

---

## Project Overview

The project has two main R scripts that:

1. **Collect tweets** about stocks via the Twitter API (hashtags and cashtags).
2. **Build text corpora** and preprocess tweets (remove URLs, punctuation, stopwords, emojis).
3. **Create document-term matrices** and extract frequent terms.
4. **Compute sentiment scores** using positive/negative word lexicons.
5. **Visualize** with word clouds and stock price charts (quantmod, and googleVis in one script).

---

## Repository Contents

| File / folder | Description |
|---------------|-------------|
| **TwitterStocks_GainersLosers.R** | Main script: **top gainers vs top losers**. Fetches tweets for GWW, ACBFF, CGC (losers) and I, ARRY, CRSP (gainers), builds corpuses, DTMs, word clouds, sentiment bar chart, candlestick charts, and googleVis line charts. |
| **EXTRA_TwitterStocks_HandSelected.R** | **Hand-selected stocks** (AAPL, GM, GOOGL, JNJ, CVIA, AU, SPY). Date range 2018-10-08 to 2018-10-12. Same pipeline: tweets → corpus → preprocessing → DTM → word clouds → sentiment bar chart → candlestick charts. Saves corpuses and DTMs to `.RData` files. |
| **twitter_keys.r** | Twitter API credentials (API key/secret, access token/secret). **Do not commit real keys.** Use a local copy or environment variables. |
| **positive-words.txt** | Positive sentiment lexicon (referenced by both scripts; not in repo — see *Requirements*). |
| **negative-words.txt** | Negative sentiment lexicon (referenced by both scripts; not in repo — see *Requirements*). |
| **handselectedDTMs.RData** | Saved document-term matrices from hand-selected stocks script. |
| **handselectedCorpuses.RData** | Saved text corpuses from hand-selected stocks script. |
| **gainersCorpuses.RData** | Saved corpuses for gainers/losers script. |
| **gainersLosersDTMs.RData** | Saved document-term matrices for gainers/losers script. |
| **Paul_Roche_CS688_FinalProject.pptx** | Final project presentation (PowerPoint). |
| **Roche_CS688_FinalProject.docx** | Final project report (Word). |
| **LICENSE** | MIT License. |
| **.gitignore** | Ignores `.httr-oauth` (OAuth cache). |

---

## Requirements

### R packages

- **twitteR** — Twitter API
- **ROAuth** — OAuth for Twitter
- **RCurl**, **bitops**, **rjson** — HTTP/JSON support
- **quantmod** — Stock data and charts (Yahoo Finance)
- **tm** — Text mining (corpus, DTM)
- **SnowballC** — Stemming (optional)
- **wordcloud** — Word clouds
- **googleVis** — Interactive charts (used in `TwitterStocks_GainersLosers.R`)

Install from CRAN, e.g.:

```r
install.packages(c("twitteR", "ROAuth", "RCurl", "bitops", "rjson", "quantmod", "tm", "SnowballC", "wordcloud", "googleVis"))
```

### Twitter API

- A Twitter Developer account and app with API keys.
- In **twitter_keys.r**, set:
  - `t.api.key`, `t.api.secret`
  - `t.access.key`, `t.access.secret`

**Security:** Do not commit real keys. Keep `twitter_keys.r` local or use environment variables and load them in R.

### Sentiment lexicons

Both scripts expect in the working directory:

- **positive-words.txt** — one word per line; lines starting with `;` are comments.
- **negative-words.txt** — same format.

Common sources: [Hu and Liu sentiment word lists](https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html) or similar lexicons in this format.

---

## How to Run

1. **Set up R and install** the packages above.
2. **Create `twitter_keys.r`** with your Twitter API credentials (see *Twitter API*).
3. **Obtain** `positive-words.txt` and `negative-words.txt` and place them in the project directory.
4. **Set the working directory** in each script to your project folder (the scripts use `setwd(dir)` with a path you may need to change).
5. **Run**:
   - **TwitterStocks_GainersLosers.R** — gainers vs losers analysis and googleVis charts.
   - **EXTRA_TwitterStocks_HandSelected.R** — hand-selected stocks and date range 2018-10-08–2018-10-12.

Note: Twitter’s free API has changed since the scripts were written; you may need to adjust authentication (e.g. OAuth 2.0) and rate limits.

---

## Script Summary

### TwitterStocks_GainersLosers.R

- **Stocks:** Losers — GWW, ACBFF, CGC; Gainers — I, ARRY, CRSP.
- **Steps:** Fetch tweets → `createCorpus()` → `preprocessCorpus()` → DTM (word length ≥ 3, global freq ≥ 2) → frequent terms → word clouds → sentiment with lexicons → bar plot (Losers vs Gainers) → `getSymbols` + `chartSeries` candlesticks → googleVis line charts merged for all symbols.
- **Outputs:** `losersCorpuses.RData`, `gainersCorpuses.RData`, `gainersLosersDTMs.RData`.

### EXTRA_TwitterStocks_HandSelected.R

- **Stocks:** AAPL, GM, GOOGL, JNJ, CVIA, AU, SPY. **Dates:** 2018-10-08 to 2018-10-12.
- **Steps:** Fetch tweets by `#TICKER` and `$TICKER` → extract text → build corpus per stock → preprocess (URLs, punctuation, lowercase, stopwords, emojis) → DTM (word length ≥ 3, global freq ≥ 4) → frequent terms → word clouds → same sentiment function and bar plot → candlestick charts for each symbol.
- **Outputs:** `handselectedDTMs.RData`, `handselectedCorpuses.RData`.

---

## License

MIT License — see **LICENSE**.
