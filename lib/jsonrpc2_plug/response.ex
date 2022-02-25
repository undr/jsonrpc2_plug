defmodule JSONRPC2Plug.Response do
  @type id :: String.t() | number() | nil
  @type method :: String.t()
  @type params :: list() | map()
  @type t :: %__MODULE__{
    id: id(),
    result: term(),
    jsonrpc: String.t()
  }

  defstruct [:id, :result, jsonrpc: "2.0"]

  @spec new(id(), term()) :: t()
  def new(id, result),
    do: %__MODULE__{id: id, result: result}
end
