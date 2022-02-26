defmodule JSONRPC2Plug.Error do
  @type id :: String.t() | number() | nil
  @type code :: integer()
  @type raw_code :: integer() | atom()
  @type message :: String.t()
  @type data :: String.t() | map() | keyword()
  @type error :: %{
    :code => code(),
    :message => message(),
    optional(:data) => data()
  }

  @type t :: %__MODULE__{
    id: id(),
    error: error(),
    jsonrpc: String.t()
  }

  defstruct [:id, :error, jsonrpc: "2.0"]

  @errors [
    parse_error: {-32700, "Parse error"},
    invalid_request: {-32600, "Invalid request"},
    method_not_found: {-32601, "Method not found"},
    invalid_params: {-32602, "Invalid params"},
    internal_error: {-32603, "Internal error"},
    server_error: {-32000, "Server error"}
  ]

  @spec code2error(atom()) :: {code(), message()}
  def code2error(code),
    do: Keyword.get(@errors, code, {-32603, "Internal error"})

  @doc """
  Create error struct with predefined errors.

  Example:
      iex> Error.new("123", :invalid_request)
      %Error{id: "123", error: %{code: -32600, message: "Invalid request"}, jsonrpc: "2.0"}
  """
  @spec new(id(), atom()) :: t()
  def new(id, code),
    do: %__MODULE__{id: id, error: error(code)}

  @doc """
  Create error struct.

  Example:
      iex> Error.new("123", :invalid_params, %{"x" => ["is not a integer"]})
      %Error{id: "123", error: %{code: -32602, message: "Invalid params", data: %{"x" => ["is not a integer"]}}, jsonrpc: "2.0"}

      iex> Error.new("123", 500, "Some valuable error")
      %Error{id: "123", error: %{code: 500, message: "Some valuable error"}, jsonrpc: "2.0"}
  """
  @spec new(id(), raw_code(), message() | data()) :: t()
  def new(id, code, message_or_data),
    do: %__MODULE__{id: id, error: error(code, message_or_data)}

  @doc """
  Create error struct with custom errors.

  Example:

      iex> Error.new("123", 500, "Some valuable error", "details")
      %Error{id: "123", error: %{code: 500, message: "Some valuable error", data: "details"}, jsonrpc: "2.0"}
  """
  @spec new(id(), raw_code(), message(), data()) :: t()
  def new(id, code, message, data),
    do: %__MODULE__{id: id, error: error(code, message, data)}

  @spec error(atom()) :: error()
  defp error(code) when is_atom(code) do
    {code, message} = code2error(code)
    %{code: code, message: message}
  end

  @spec error(atom(), data()) :: error()
  defp error(code, data) when is_atom(code) do
    {code, message} = code2error(code)
    %{code: code, message: message, data: data}
  end

  @spec error(integer(), message()) :: error()
  defp error(code, message) when is_number(code),
    do: %{code: code, message: message}

  @spec error(integer(), message(), data()) :: error()
  defp error(code, message, data) when is_number(code),
    do: %{code: code, message: message, data: data}
end
