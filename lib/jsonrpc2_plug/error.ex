defmodule JSONRPC2Plug.Error do
  defstruct [:id, :error, jsonrpc: "2.0"]

  @errors [
    parse_error: {-32700, "Parse error"},
    invalid_request: {-32600, "Invalid request"},
    method_not_found: {-32601, "Method not found"},
    invalid_params: {-32602, "Invalid params"},
    internal_error: {-32603, "Internal error"},
    server_error: {-32000, "Server error"}
  ]

  def code2error(code),
    do: Keyword.get(@errors, code, {-32603, "Internal error"})

  def new(id, code),
    do: %__MODULE__{id: id, error: error(code)}
  def new(id, code, message_or_data),
    do: %__MODULE__{id: id, error: error(code, message_or_data)}
  def new(id, code, message, data),
    do: %__MODULE__{id: id, error: error(code, message, data)}

  defp error(code) when is_atom(code) do
    {code, message} = code2error(code)
    %{code: code, message: message}
  end
  defp error(code, data) when is_atom(code) do
    {code, message} = code2error(code)
    %{code: code, message: message, data: data}
  end
  defp error(code, message) when is_number(code),
    do: %{code: code, message: message}
  defp error(code, message, data) when is_number(code),
    do: %{code: code, message: message, data: data}
end
