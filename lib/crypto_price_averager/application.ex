defmodule CryptoPriceAverager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CryptoPriceAverager.SubscriptionManager,   # Starts SubscriptionManager first
      CryptoPriceAverager.BinanceClient,         # Starts WebSocketClient second
      CryptoPriceAverager.PriceManager           # Starts PriceManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoPriceAverager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
