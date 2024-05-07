defmodule CryptoPriceAverager.PriceManager do
  use GenServer

  defstruct prices: %{}, last_processed: %{}

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %CryptoPriceAverager.PriceManager{}, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  # Handles incoming message from WebSocketClient
  def handle_msg(%{"s" => symbol, "c" => last_price, "E" => timestamp}) do
    GenServer.call(__MODULE__, {:update, symbol, Decimal.new(last_price), timestamp})
  end

  def handle_call({:update, symbol, last_price, timestamp}, _from, %CryptoPriceAverager.PriceManager{} = state) do
    # Check if the message has already been processed
    case Map.get(state.last_processed, symbol) do
      ^timestamp ->
        # If timestamp matches, do nothing and return the current state
        {:reply, :ok, state}

      _ ->
        # If not, update the prices and record the timestamp
        prices = Map.get(state.prices, symbol, [])
        prices = [last_price | prices] |> Enum.take(100)  # Keep last 100 prices
        average = Enum.reduce(prices, &Decimal.add/2) |> Decimal.div(Decimal.new(length(prices)))

        # Log the average price and the symbol
        IO.puts("Average price for #{symbol}: #{Decimal.to_string(average)}")

        new_state = %CryptoPriceAverager.PriceManager{
          prices: Map.put(state.prices, symbol, prices),
          last_processed: Map.put(state.last_processed, symbol, timestamp)
        }
        {:reply, average, new_state}
    end
  end

  def handle_call({:get_prices, symbol}, _from, state) do
    prices = Map.get(state.prices, symbol, [])
    {:reply, {:ok, prices}, state}
  end
end
