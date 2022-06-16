defmodule JSONRPC2Plug.Validator.Dataset do
  @type dataset :: t() | map()
  @type unwrapped :: {:ok, map()} | {:invalid, map()}
  @type t :: %__MODULE__{
    data: map(),
    errors: keyword()
  }

  defstruct [:data, errors: []]

  @spec wrap(dataset()) :: t()
  def wrap(%__MODULE__{} = result),
    do: result
  def wrap(data),
    do: %__MODULE__{data: data}

  @spec get_value(t(), String.t()) :: term()
  def get_value(%__MODULE__{data: data}, key),
    do: get_in(data, String.split(key, "."))

  @spec add_error(t(), String.t(), String.t()) :: t()
  def add_error(%__MODULE__{} = result, key, reason) when is_binary(reason),
    do: add_error(result, key, {reason, []})

  @spec add_error(t(), String.t(), {String.t(), keyword()}) :: t()
  def add_error(%__MODULE__{errors: errors} = result, key, reason) do
    errors =
      Keyword.update(errors, String.to_atom(key), [reason], fn(other_reasons) ->
        [reason | other_reasons]
      end)

    %__MODULE__{result | errors: errors}
  end

  @spec unwrap(t()) :: unwrapped()
  def unwrap(%__MODULE__{data: data, errors: []}),
    do: {:ok, data}
  def unwrap(%__MODULE__{errors: errors}),
    do: {:invalid, error_messages(errors)}

  defp error_messages(errors, messages \\ [])
  defp error_messages([], messages),
    do: Enum.into(messages, %{})
  defp error_messages([{key, key_errors} | errors], messages) do
    key_messages = Enum.map(key_errors, fn({msg, opts}) -> gettext(msg, opts) end)
    error_messages(errors, [{key, key_messages} | messages])
  end

  defp gettext(msg, opts) do
    backend = Application.get_env(
      :jsonrpc2_plug, JSONRPC2Plug.Gettext.Backend, JSONRPC2Plug.Gettext
    )

    Gettext.dgettext(backend, "errors", msg, opts)
  end
end
