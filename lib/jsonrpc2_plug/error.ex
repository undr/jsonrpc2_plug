defmodule JSONRPC2Plug.Error do
  defstruct [:id, :error, jsonrpc: "2.0"]

  @errors [
    parse_error: {-32700, "Parse error"},
    invalid_request: {-32600, "Invalid Request"},
    method_not_found: {-32601, "Method not found"},
    invalid_params: {-32602, "Invalid params"},
    internal_error: {-32603, "Internal error"},
    server_error: {-32000, "Server error"}
  ]

  def new(id, code, message),
    do: %__MODULE__{id: id, error: %{code: code, message: message}}
  def new(id, code, message, data),
    do: %__MODULE__{id: id, error: %{code: code, message: message, data: data}}

  def error(type),
    do: error(type, nil)
  def error(type, id) do
    case Keyword.get(@errors, type) do
      {code, message} ->
        new(id, code, message)

      nil ->
        new(id, -32000, "Internal error")
    end
  end
end
