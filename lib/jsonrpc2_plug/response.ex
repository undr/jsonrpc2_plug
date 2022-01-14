defmodule JSONRPC2Plug.Response do
  defstruct [:id, :result, jsonrpc: "2.0"]

  def new(id, result),
    do: %__MODULE__{id: id, result: result}
end
