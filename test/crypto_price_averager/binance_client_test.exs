defmodule CryptoPriceAverager.BinanceClientTest do
  use ExUnit.Case

  test "start_link/0 starts the WebSocket connection" do
    {:ok, _pid} = CryptoPriceAverager.BinanceClient.start_link(name: :test_client)
  end

  test "handle_disconnect/2 logs disconnection" do
    state = %{}
    assert {:ok, _new_state} = CryptoPriceAverager.BinanceClient.handle_disconnect(nil, state)
  end

  test "subscribe/1 subscribes to valid cryptos" do
    cryptos = ["btcusdt@ticker", "ethusdt@ticker"]
    assert :ok = CryptoPriceAverager.BinanceClient.subscribe(cryptos)
    assert CryptoPriceAverager.SubscriptionManager.get_subscriptions() == cryptos
  end

  test "unsubscribe/1 unsubscribes from cryptos" do
    cryptos = ["btcusdt@ticker", "ethusdt@ticker"]
    assert :ok = CryptoPriceAverager.BinanceClient.unsubscribe(cryptos)
    assert CryptoPriceAverager.SubscriptionManager.get_subscriptions() == []
  end

  test "handle_frame/2 processes received messages" do
    state = %{}
    frame = {:text, "{\"s\":\"BTCUSDT\",\"c\":\"50000\",\"E\":1620856332084}"}
    assert {:ok, _new_state} = CryptoPriceAverager.BinanceClient.handle_frame(frame, state)
    # Add assertions for message processing
  end

  test "valid_subscription?/1 returns false for invalid subscriptions" do
    refute CryptoPriceAverager.BinanceClient.valid_subscription?("invalid")
  end

  test "valid_subscription?/1 returns true for valid subscriptions" do
    assert CryptoPriceAverager.BinanceClient.valid_subscription?("btcusdt@ticker")
  end
end
