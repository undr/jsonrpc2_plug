defmodule Jsonrpc2Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsonrpc2_plug,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      maintainers: ["Andrei Lepeshkin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/undr/jsonrpc2_plug"}
    ]
  end

  def description do
    "JSONRPC2Plug is an Elixir library for a JSON-RPC 2.0 server. " <>
    "Can be used as the plug middleware or as a standalone transport-agnostic server handler."
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
      {:plug, "~> 1.12"},
      {:poison, "~> 4.0"},
      {:gettext, "~> 0.19.0"},
      {:dialyxir, "~> 1.2.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
