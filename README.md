### Installation

1. **Clone the repository to your local machine:**

   ```bash
   git clone https://github.com/your-username/crypto-price-averager.git
   ```

2. Navigate to the project directory:

   ```bash
   cd crypto_price_averager
   ```

**Usage**
1. Start the application in Interactive Elixir (iex):

   ```bash
   iex -S mix
   ```

2. Subscribe to a cryptocurrency pair:

   ```bash
   CryptoPriceAverager.BinanceClient.subscribe(["btcusdt@ticker"])
   ```

View the average prices in the console.

3. Subscribe to another cryptocurrency pair:

   ```bash
   CryptoPriceAverager.BinanceClient.subscribe(["ethusdt@ticker"])
   ```

View the average prices for all subscribed pairs in the console.

4. Unsubscribe from a cryptocurrency pair:

   ```bash
   CryptoPriceAverager.BinanceClient.unsubscribe(["ethusdt@ticker"])
   ```

5. View the average prices only for the remaining subscribed pairs in the console.