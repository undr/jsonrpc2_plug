defmodule JSONRPC2Plug.Validator.Number do
  alias JSONRPC2Plug.Validator.Rule

  use JSONRPC2Plug.Validator.Rule

  @spec check(Rule.value(), Rule.opts()) :: Rule.result()
  def check(nil, _opts),
    do: :ok
  def check(value, opts)  do
    if is_number(value) do
      Enum.reduce(opts, :ok, fn
        (rule, :ok) ->
          check_number(value, rule)

        (_, err) ->
          err
      end)
    else
      error("is not a %{type}", type: :number)
    end
  end

  defp check_number(number, {:equal_to, value}) do
    if number == value do
      :ok
    else
      error("must be equal to %{value}", value: value)
    end
  end

  defp check_number(number, {:gt, value}) do
    if number > value do
      :ok
    else
      error("must be greater than %{value}", value: value)
    end
  end

  defp check_number(number, {:gte, value}) do
    if number >= value do
      :ok
    else
      error("must be greater than or equal to %{value}", value: value)
    end
  end

  defp check_number(number, {:min, value}) do
    check_number(number, {:gte, value})
  end

  defp check_number(number, {:lt, value}) do
    if number < value do
      :ok
    else
      error("must be less than %{value}", value: value)
    end
  end

  defp check_number(number, {:lte, value}) do
    if number <= value do
      :ok
    else
      error("must be less than or equal to %{value}", value: value)
    end
  end

  defp check_number(number, {:max, value}),
    do: check_number(number, {:lte, value})

  defp check_number(_number, {rule, _value}),
    do: error("unknown rule '%{rule}'", rule: rule)
end
