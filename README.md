# JSONRPC2.Plug

An Elixir `plug` library for extending an HTTP server with JSONRPC 2.0 protocol services. It's HTTP transport level. For use both in the Phoenix application and pure `plug`-compatable server.

## Installation

The package can be installed by adding `jsonrpc2_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jsonrpc2_plug, "~> 2.0.0"}
  ]
end
```

## Usage

### Services

It uses [`jsonrpc2_service`](https://github.com/undr/jsonrpc2_service) library for service creation.

### Pure `plug`-compatable server

```elixir
use Plug.Router

forward "/jsonrpc", to: JSONRPC2.Plug, init_opts: CalculatorService
```

`CalculatorService` is a service build by [`jsonrpc2_service`](https://github.com/undr/jsonrpc2_service) library

You can handle errors outside of `plug`. Add `Plug.ErrorHandler` into a router and define `&handle_errors/2` function ([read more](https://hexdocs.pm/plug/Plug.ErrorHandler.html)). 

```elixir
  use Plug.ErrorHandler

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    kind |> Exception.format(reason, stacktrace) |> Logger.error()

    case conn do
      %{request_path: "/jsonrpc"} ->
        JSONRPC2.Plug.send_error(conn, kind, reason)

      _ ->
        send_resp(conn, 500, "Someting went wrong")
    end
  end
```

### Phoenix server

```elixir

forward "/jsonrpc", JSONRPC2.Plug, CalculatorService
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jsonrpc2_plug](https://hexdocs.pm/jsonrpc2_plug).
