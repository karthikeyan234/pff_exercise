defmodule CryptoPriceAverager.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_price_averager,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CryptoPriceAverager.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.4"},
      {:decimal, "~> 2.0"},
      {:mock, "~> 0.3.8", only: :test}
    ]
  end
end
