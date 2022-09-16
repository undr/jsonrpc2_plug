defmodule JSONRPC2Plug.Validator do
  alias JSONRPC2Plug.Validator.Rule
  alias JSONRPC2Plug.Validator.Type
  alias JSONRPC2Plug.Validator.Number
  alias JSONRPC2Plug.Validator.Length
  alias JSONRPC2Plug.Validator.Inclusion
  alias JSONRPC2Plug.Validator.Exclusion
  alias JSONRPC2Plug.Validator.Dataset

  @type validator :: (Rule.value() -> Rule.result())

  defmacro __using__(_) do
    :functions
    |> __MODULE__.__info__()
    |> Enum.map(fn({func, arity}) ->
      arguments = 0..10
      |> Enum.take(arity)
      |> Enum.map(&(:"arg#{&1}"))
      |> Enum.map(&Macro.var(&1, nil))

      quote location: :keep do
        def unquote(func)(unquote_splicing(arguments)) do
          unquote(__MODULE__).unquote(func)(unquote_splicing(arguments))
        end
      end
    end)
  end

  @spec required() :: validator()
  def required do
    fn(value) ->
      case value do
        nil  -> {:error, "is required", []}
        _any -> :ok
      end
    end
  end

  @spec not_empty() :: validator()
  def not_empty do
    fn(value) ->
      case value do
        ""   -> {:error, "is empty", []}
        []   -> {:error, "is empty", []}
        %{}  -> {:error, "is empty", []}
        _any -> :ok
      end
    end
  end

  @spec format(Regex.t()) :: validator()
  def format(regex) do
    fn(value) ->
      if is_nil(value) || (is_binary(value) && Regex.match?(regex, value)) do
        :ok
      else
        {:error, "does not match format %{format}", [format: Regex.source(regex)]}
      end
    end
  end

  @spec exclude(Enumerable.t()) :: validator()
  def exclude(enum),
    do: Exclusion.rule(in: enum)

  @spec include(Enumerable.t()) :: validator()
  def include(enum),
    do: Inclusion.rule(in: enum)

  @spec len(Rule.opts()) :: validator()
  def len(opts),
    do: Length.rule(opts)

  @spec number(Rule.opts()) :: validator()
  def number(opts),
    do: Number.rule(opts)

  @spec type(atom() | {:array, atom()}) :: validator()
  def type(typename),
    do: Type.rule(type: typename)

  @spec validate(Dataset.dataset(), String.t(), [validator(), ...]) :: Dataset.t()
  def validate(data, key, validators) do
    dataset = Dataset.wrap(data)
    value = Dataset.get_value(dataset, key)
    validate_key_value(key, value, validators, dataset)
  end

  @spec unwrap(Dataset.t()) :: Dataset.unwrapped()
  def unwrap(dataset),
    do: Dataset.unwrap(dataset)

  defp validate_key_value(_key, _value, [], dataset),
    do: dataset
  defp validate_key_value(key, value, [validator | validators], dataset) do
    case validator.(value) do
      :ok ->
        validate_key_value(key, value, validators, dataset)

      {:error, reason, opts} ->
        Dataset.add_error(dataset, key, {reason, opts})
    end
  end
end
