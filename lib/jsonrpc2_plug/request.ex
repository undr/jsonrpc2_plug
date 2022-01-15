defmodule JSONRPC2Plug.Request do
  defstruct [:id, :method, :params]

  def parse(%{"id" => id, "method" => method, "params" => params, "jsonrpc" => "2.0"}),
    do: {:ok, %__MODULE__{id: id, method: method, params: params}}
  def parse(%{"id" => id}),
    do: {:invalid, id}
  def parse(_),
    do: {:invalid, nil}

  def valid?(%__MODULE__{id: _, method: method, params: params}),
    do: if(is_binary(method) && (is_list(params) || is_map(params)), do: :ok, else: :invalid)
end
