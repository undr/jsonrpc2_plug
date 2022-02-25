defmodule JSONRPC2Plug.Validator.Type do
  alias JSONRPC2Plug.Validator.Rule

  use JSONRPC2Plug.Validator.Rule

  @spec check(Rule.value(), Rule.opts()) :: Rule.result()
  def check(value, opts \\ []) do
    {:ok, type} = Keyword.fetch(opts, :type)
    check_type(type, value)
  end

  defp check_type(_any, nil),
    do: :ok
  defp check_type(:boolean, value) when is_boolean(value),
    do: :ok
  defp check_type(:integer, value) when is_integer(value),
    do: :ok
  defp check_type(:float, value) when is_float(value),
    do: :ok
  defp check_type(:number, value) when is_number(value),
    do: :ok
  defp check_type(:string, value) when is_binary(value),
    do: :ok
  defp check_type(:array, value) when is_list(value),
    do: :ok
  defp check_type(:object, value) when is_map(value),
    do: :ok
  defp check_type({:array, type}, value) when is_list(value),
    do: array(value, &check_type(type, &1))

  defp check_type(type, _) when is_tuple(type),
    do: error("is not a %{type}", [type: :array])
  defp check_type(type, _),
    do: error("is not a %{type}", [type: type])

  defp array(data, func, acc \\ [])
  defp array([], _func, _acc),
    do: :ok
  defp array([h | t], func, acc) do
    case func.(h) do
      :ok ->
          array(t, func, [h | acc])

      {:error, msg, opts} ->
        {:error, "content #{msg}", opts}
    end
  end
end
