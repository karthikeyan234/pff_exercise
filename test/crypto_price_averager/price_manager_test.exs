defmodule CryptoPriceAverager.PriceManagerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = CryptoPriceAverager.PriceManager.start_link(name: :test_price_manager)
    {:ok, pid: pid}
  end

  test "updates price data correctly", %{pid: pid} do
    GenServer.call(pid, {:update, "btcusdt", Decimal.new("50000"), 1})
    {:ok, prices} = GenServer.call(pid, {:get_prices, "btcusdt"})  # Assume this function exists
    assert prices == [Decimal.new("50000")]
  end

  test "handles duplicate timestamps", %{pid: pid} do
    GenServer.call(pid, {:update, "btcusdt", Decimal.new("50000"), 1})
    response = GenServer.call(pid, {:update, "btcusdt", Decimal.new("50000"), 1})
    assert response == :ok  # Expect no update due to duplicate

    {:ok, prices} = GenServer.call(pid, {:get_prices, "btcusdt"})
    assert prices == [Decimal.new("50000")]  # Still only one entry
  end
end
