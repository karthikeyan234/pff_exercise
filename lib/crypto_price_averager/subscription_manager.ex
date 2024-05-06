defmodule CryptoPriceAverager.SubscriptionManager do
  use GenServer

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, MapSet.new(), name: name)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def get_subscriptions do
    GenServer.call(__MODULE__, :get_subscriptions)
  end

  def get_subscriptions(pid) do
    GenServer.call(pid, :get_subscriptions)
  end

  def add_subscription(cryptos) do
    GenServer.cast(__MODULE__, {:add_subscription, cryptos})
  end

  def remove_subscription(cryptos) do
    GenServer.cast(__MODULE__, {:remove_subscription, cryptos})
  end

  def handle_call(:get_subscriptions, _from, state) do
    {:reply, MapSet.to_list(state), state}
  end

  def handle_cast({:add_subscription, cryptos}, state) do
    validated_cryptos = validate_subscriptions(cryptos)
    new_state = MapSet.union(state, MapSet.new(validated_cryptos))
    {:noreply, new_state}
  end

  def handle_cast({:remove_subscription, cryptos}, state) do
    validated_cryptos = validate_subscriptions(cryptos)
    new_state = MapSet.difference(state, MapSet.new(validated_cryptos))
    {:noreply, new_state}
  end

  # Validate each crypto subscription format and normalize to lowercase
  defp validate_subscriptions(cryptos) do
    cryptos
    |> Enum.map(&String.downcase/1)
    |> Enum.filter(&valid_subscription?/1)
  end

  # Check if the subscription format is valid
  defp valid_subscription?(crypto) do
    String.contains?(crypto, "@ticker") && String.length(crypto) > 7
  end
end
