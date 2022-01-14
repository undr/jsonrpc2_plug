defmodule JSONRPC2Plug.Request do
  defstruct [:id, :method, :params]

  alias JSONRPC2Plug.Error

  def parse([]),
    do: Error.error(:invalid_request)
  def parse(data) when is_list(data),
    do: Enum.map(data, &parse_one/1)
  def parse(data),
    do: parse_one(data)

  def valid?(%__MODULE__{id: _, method: method, params: params}),
    do: is_binary(method) && (is_list(params) || is_map(params))

  defp parse_one(%{"id" => id, "method" => method, "params" => params, "jsonrpc" => "2.0"}),
    do: %__MODULE__{id: id, method: method, params: params}
  defp parse_one(%{"id" => id}),
    do: Error.error(:invalid_request, id)
  defp parse_one(_),
    do: Error.error(:invalid_request)
end
