defmodule CryptoPriceAverager.BinanceClient do
  use WebSockex
  require Logger

  @url "wss://stream.binance.com:9443/ws/stream"

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    WebSockex.start_link(@url, __MODULE__, %{}, name: name)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected to WebSocket.")
    subscribe_active_pairs()
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    Logger.info("Disconnected from WebSocket.")
    {:ok, state}
  end

  defp subscribe_active_pairs do
    CryptoPriceAverager.SubscriptionManager.get_subscriptions()
    |> Enum.each(&subscribe/1)
  end

  def subscribe(cryptos) do
    validated_cryptos = validate_subscriptions(cryptos)
    Logger.debug("Subscribing to: #{inspect(validated_cryptos)}")
    send_subscription(validated_cryptos, "SUBSCRIBE")
    CryptoPriceAverager.SubscriptionManager.add_subscription(cryptos)
  end

  def unsubscribe(cryptos) do
    validated_cryptos = validate_subscriptions(cryptos)
    Logger.debug("Unsubscribing from: #{inspect(validated_cryptos)}")
    send_subscription(validated_cryptos, "UNSUBSCRIBE")
    CryptoPriceAverager.SubscriptionManager.remove_subscription(cryptos)
  end

  defp send_subscription(cryptos, method) do
    cryptos
    |> Enum.each(fn crypto ->
      frame = build_frame([crypto], method)
      WebSockex.send_frame(__MODULE__, frame)
    end)
  end

  defp build_frame(cryptos, method) do
    message = %{
      "id" => 1,
      "params" => cryptos,
      "method" => method
    } |> Jason.encode!()
    {:text, message}
  end

  def handle_frame({type, msg}, state) do
    Logger.debug("Received Message - Type: #{type}, Message: #{msg}")
    process_message(msg, state)
  end

  defp process_message(msg, state) do
    case Jason.decode(msg) do
      {:ok, decoded} -> handle_msg(decoded, state)
      {:error, _error} -> Logger.error("Failed to decode message: #{msg}")
    end
    {:ok, state}
  end

  def handle_msg(%{"s" => symbol, "c" => last_price, "E" => timestamp}, state) do
    CryptoPriceAverager.PriceManager.handle_msg(%{"s" => symbol, "c" => last_price, "E" => timestamp})
    {:ok, state}
  end

  def handle_msg(_, state), do: {:ok, state}

  # Validate each crypto subscription format and normalize to lowercase
  def validate_subscriptions(cryptos) do
    cryptos
    |> Enum.map(&String.downcase/1)
    |> Enum.filter(&valid_subscription?/1)
  end

  # Check if the subscription format is valid
  def valid_subscription?(crypto) do
    String.contains?(crypto, "@ticker") && String.length(crypto) > 7
  end
end
