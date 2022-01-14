defmodule Jsonrpc2Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsonrpc2_plug,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:plug, "~> 1.12"},
      {:dialyxir, "~> 0.3", only: :dev}
    ]
  end
end
