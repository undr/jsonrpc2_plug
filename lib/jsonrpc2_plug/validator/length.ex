defmodule JSONRPC2Plug.Validator.Length do
  alias JSONRPC2Plug.Validator.Rule
  alias JSONRPC2Plug.Validator.Number

  use JSONRPC2Plug.Validator.Rule

  @spec check(Rule.value(), Rule.opts()) :: Rule.result()
  def check(value, opts) do
    with {:ok, length} <- get_length(value),
         :ok <- Number.check(length, opts) do
      :ok
    else
      {:error, :wrong_type} ->
        error("length check supports only arrays, strings and objects")

      {:error, msg, opts} ->
        error("length #{msg}", opts)
    end
  end

  defp get_length(param) when is_list(param),
    do: {:ok, length(param)}
  defp get_length(param) when is_binary(param),
    do: {:ok, String.length(param)}
  defp get_length(param) when is_map(param),
    do: {:ok, map_size(param)}
  defp get_length(_param),
    do: {:error, :wrong_type}
end
