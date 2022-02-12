defmodule JSONRPC2Plug.Validator.Dataset do
  defstruct [:data, errors: []]

  def wrap(%__MODULE__{} = result),
    do: result
  def wrap(data),
    do: %__MODULE__{data: data}

  def get_value(%__MODULE__{data: data}, key),
    do: get_in(data, String.split(key, "."))

  def add_error(%__MODULE__{} = result, key, reason) when is_binary(reason),
    do: add_error(result, key, {reason, []})
  def add_error(%__MODULE__{errors: errors} = result, key, reason) do
    errors =
      Keyword.update(errors, String.to_atom(key), [reason], fn(other_reasons) ->
        [reason | other_reasons]
      end)

    %__MODULE__{result | errors: errors}
  end

  def unwrap(%__MODULE__{data: data, errors: []}),
    do: {:ok, data}
  def unwrap(%__MODULE__{errors: errors}),
    do: {:invalid, error_messages(errors)}

  defp error_messages(errors, messages \\ [])
  defp error_messages([], messages),
    do: messages
  defp error_messages([{key, key_errors} | errors], messages) do
    key_messages = Enum.map(key_errors, fn({msg, opts}) -> gettext(msg, opts) end)
    error_messages(errors, [{key, key_messages} | messages])
  end

  defp gettext(msg, opts),
    do: Gettext.dgettext(JSONRPC2Plug.Gettext, "errors", msg, opts)
end
