defmodule CryptoPriceAverager.SubscriptionManagerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = CryptoPriceAverager.SubscriptionManager.start_link(name: :test_subscription_manager)
    {:ok, pid: pid}
  end

  test "adds and removes subscriptions", %{pid: pid} do
    GenServer.cast(pid, {:add_subscription, ["btcusdt@ticker"]})
    Process.sleep(100)
    assert ["btcusdt@ticker"] == CryptoPriceAverager.SubscriptionManager.get_subscriptions(pid)

    GenServer.cast(pid, {:remove_subscription, ["btcusdt@ticker"]})
    Process.sleep(100)
    assert [] == CryptoPriceAverager.SubscriptionManager.get_subscriptions(pid)
  end
end
