defmodule AddMethod do
  use JSONRPC2Plug.Method

  alias JSONRPC2Plug.Validator
  require JSONRPC2Plug.Validator, [type: 1, required: 0]

  def handle_call(%{"x" => x, "y" => y}),
    do: {:ok, x + y}

  def validate(params) do
    params
    |> Validator.validate("x", [type(:integer), required()])
    |> Validator.validate("y", [type(:integer), required()])
    |> Validator.unwrap()
  end
end
