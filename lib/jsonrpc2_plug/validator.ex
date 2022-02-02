defmodule JSONRPC2Plug.Validator do
  alias JSONRPC2Plug.Validator.Type
  alias JSONRPC2Plug.Validator.Number
  alias JSONRPC2Plug.Validator.Length
  alias JSONRPC2Plug.Validator.Inclusion
  alias JSONRPC2Plug.Validator.Exclusion
  alias JSONRPC2Plug.Validator.Input

  def required do
    fn(value) ->
      case value do
        nil  -> {:error, "is required", []}
        _any -> :ok
      end
    end
  end

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

  def format(regex) do
    fn(value) ->
      if is_nil(value) || (is_binary(value) && Regex.match?(regex, value)) do
        :ok
      else
        {:error, "does not match format %{format}", [format: regex]}
      end
    end
  end

  def exclude(enum),
    do: Exclusion.rule(in: enum)

  def include(enum),
    do: Inclusion.rule(in: enum)

  def len(opts),
    do: Length.rule(opts)

  def number(opts),
    do: Number.rule(opts)

  def type(typename),
    do: Type.rule(type: typename)

  def validate(data, key, validators) do
    input = Input.wrap(data)
    value = Input.get_value(input, key)
    validate_key_value(key, value, validators, input)
  end

  def unwrap(input),
    do: Input.unwrap(input)

  defp validate_key_value(_key, _value, [], input),
    do: input
  defp validate_key_value(key, value, [validator | validators], input) do
    case validator.(value) do
      :ok ->
        validate_key_value(key, value, validators, input)

      {:error, reason, opts} ->
        Input.add_error(input, key, {reason, opts})
    end
  end
end
