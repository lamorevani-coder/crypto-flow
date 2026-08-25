# Exchange Capabilities Table

Research based on official documentation as of 2026-08-25. Primary sources: official API docs of each exchange.

## Aggressor Side Determination (Critical for Delta)

| Exchange | Market | Field | Meaning | Aggressor Mapping | Source |
|----------|--------|-------|---------|-------------------|--------|
| Binance | Spot / Futures | `m` (isBuyerMaker) | true = buyer is maker | true → SELL, false → BUY | Official WS trade/aggTrade |
| Bybit | Spot / Linear | `S` | Side of **taker** | "Buy" → BUY, "Sell" → SELL | Official publicTrade |
| OKX | Spot / SWAP | `side` | Trade side of **taker** | "buy" → BUY, "sell" → SELL | Official trades / trades-all |
| Coinbase | Spot | `side` | Side of **maker** | "BUY" → SELL, "SELL" → BUY | Advanced Trade market_trades |
| Kraken | Spot | `side` | Side of the **taker** order | "buy" → BUY, "sell" → SELL | WS v2 trade |
| Hyperliquid | Perp | `side` | "B"=Bid (taker buy), "A"=Ask (taker sell) | "B" → BUY, "A" → SELL | Official trades subscription |
| Bitfinex | TBD | TBD | TBD | TBD | Research in progress |
| Deribit | TBD | TBD | TBD | TBD | Research in progress |

**Rule**: Prefer native maker/taker or explicit taker side. Never fall back to price change tick unless explicitly documented as unavailable.

## Symbol Formats (normalized to BTCUSDT style internally)

| Exchange | Spot Example | Perp Example | Notes |
|----------|--------------|--------------|-------|
| Binance | BTCUSDT | BTCUSDT | Lowercase in stream names |
| Bybit | BTCUSDT | BTCUSDT | Same for spot/linear |
| OKX | BTC-USDT | BTC-USDT-SWAP | Hyphenated |
| Coinbase | BTC-USD | (limited US futures) | Hyphen, USD not USDT primary |
| Kraken | BTC/USD | (Futures separate API) | Slash |
| Hyperliquid | - | BTC | Coin symbol for perps |
| Bitfinex | tBTCUSD | TBD | t prefix |
| Deribit | - | BTC-PERPETUAL | Dash |

## Supported Streams (Priority for v1)

### Binance
- Spot WS: trade, aggTrade, bookTicker, kline, depth
- Futures USDT-M: trade, aggTrade, markPrice, forceOrder (liqs), openInterest (REST), fundingRate
- Historical: REST aggTrades, trades (limited)
- Rate limits: weight based, WS 5 msg/s send, ping every 3 min
- Timestamp: ms
- Contract multiplier: 1 for USDT-M linear

### Bybit
- Spot + Linear separate WS endpoints
- publicTrade, orderbook, tickers, kline, liquidation
- Funding, mark, OI via REST or ticker
- Heartbeat: client ping every 20s
- Timestamp: ms

### OKX
- Unified public WS /ws/v5/public
- trades / trades-all, books, tickers, mark-price, funding-rate, open-interest, liquidation-orders
- instType SPOT / SWAP
- Heartbeat: standard, reconnect re-subscribe
- Timestamp: ms
- sz unit: base for spot, contracts for SWAP (ctVal needed)

### Coinbase Advanced
- market_trades, ticker, level2, candles, heartbeats
- Mostly Spot; US futures limited
- side = maker side (invert for aggressor)
- product_ids BTC-USD etc.
- Auth: public channels no JWT required (per docs), but examples often include

### Kraken
- Spot WS v2 trade, book, ticker, ohlc
- Futures separate (futures.kraken.com)
- side = taker
- Good for spot delta contribution

### Hyperliquid
- trades by coin (BTC, ETH, HYPE etc.)
- Perp focused, high relevance for GLOBAL BTC PERP
- Native side B/A

### Bitfinex & Deribit
- Research continuing. Bitfinex has tBTCUSD trades with flags for taker. Deribit has trades with direction/tickDirection or side.

## Unavailable / Calculated / Native Status (examples for BTC)

For each metric we will mark:
- native: exchange provides directly
- calculated: derived (e.g. delta = buy - sell notional)
- unavailable: not provided, will be null + data_quality flag
- approximation: only if unavoidable and documented

## Next Steps in Research
- Complete Bitfinex (https://docs.bitfinex.com/) and Deribit (https://docs.deribit.com/)
- Exact rate limit numbers and historical depth for backfill
- Contract size / multiplier for inverse contracts if used
- Liquidation stream formats

This file will be updated continuously.
