defmodule Jsonrpc2.Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsonrpc2_plug,
      version: "2.0.0",
      elixir: "~> 1.18",
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
    "An Elixir `plug` library for extending an HTTP server with JSONRPC 2.0 protocol services. " <>
      "It's HTTP transport level. For use both in the Phoenix application and pure `plug`-compatable server."
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
      {:plug, "~> 1.0"},
      {:jsonrpc2_service, "~> 0.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
