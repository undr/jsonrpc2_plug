# JSON-RPC 2.0 plug

`JSONRPC2Plug` is an Elixir library for a JSON-RPC 2.0 server. Can be used as the plug middleware or as a standalone transport-agnostic server handler.

## Installation

The package can be installed by adding `jsonrpc2_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jsonrpc2_plug, "~> 0.1.0"}
  ]
end
```

## Usage

### Defining Services

Services should use `JSONRPC2Plug.Service`, which allows describing methods of service. Each method is a module which use `JSONRPC2Plug.Method`.

Examples:


```elixir
defmodule CalculatorService do
  use JSONRPC2Plug.Service

  method "add", AddMethod
  method "subtract", SubtractMethod
  method "multiply", MultiplyMethod
  method "divide", DivideMethod
end

defmodule AddMethod do
  use JSONRPC2Plug.Method
end
# and so on...
```

### Defining Methods

There are two possible ways to execute a request: `call` and `cast`. The first assumes the response which the service will return, the second does not. The module should implement at least one `handle_call` or `handle_cast` callback function to handle requests.

```elixir
defmodule AddMethod do
  use JSONRPC2Plug.Method

  # It handles requests like this:
  # {"id": "123", "method": "add", "params": {"x": 10, "y": 20}, "jsonrpc": "2.0"}
  def handle_call(%{"x" = > x, "y" => y}, _conn) do
    {:ok, x + y}
  end
end
```

The first argument is the `"params"` data comes from request JSON. According to [JSONRPC2 spec](https://www.jsonrpc.org/specification), it must be either object or an array of arguments.

The second argument is the `Plug.Conn` struct. Sometimes it could be useful to access the `Plug` connection.

The module implements behaviour `JSONRPC2Plug.Method` which consists of five callbacks: `handle_call`, `handle_cast`, `validate`, `handle_error` and, `handle_exception`.

#### `handle_call` and `handle_cast`

_TODO: Add description_

#### `validate`

This function is for the validation of the input dataset.

```elixir
import JSONRPC2Plug.Validator, only: [type: 1, required: 0]

def validate(params) do
  params
  |> Validator.validate("x", [type(:integer), required()])
  |> Validator.validate("y", [type(:integer), required()])
  |> Validator.unwrap()
end
```

The library has its own validator. It has 8 built-in validations: `type`, `required`, `not_empty`, `exclude`, `include`, `len`, `number` and `format`. However, you can write custom validations and extend existing ones.

Moreover, you can use any preferred validator (eg. [`valdi`](https://github.com/bluzky/valdi)), but you should respect the following requirements: the `validate` function should return either `{:ok, params}` or `{:invalid, errors}`. Where `errors` could be any type that can be safely encoded to JSON and `params` is params to pass into `handle_call` or `handle_cast` functions.

#### `handle_error` and `handle_exception`

_TODO: Add description_

### Add as a plug to the router

_TODO: Add description_

### Using as standalone module

_TODO: Add description_

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jsonrpc2_plug](https://hexdocs.pm/jsonrpc2_plug).
