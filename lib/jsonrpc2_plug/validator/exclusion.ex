defmodule JSONRPC2Plug.Validator.Exclusion do
  alias JSONRPC2Plug.Validator.Rule

  use JSONRPC2Plug.Validator.Rule

  @spec check(Rule.value(), Rule.opts()) :: Rule.result()
  def check(nil, _opts),
    do: :ok
  def check(value, [{:in, enum}]) do
    if Enumerable.impl_for(enum) do
      if Enum.member?(enum, value) do
        error("is in the black list: %{list}", [list: Enum.join(enum, ", ")])
      else
        :ok
      end
    else
      error("is in the black list: %{list}", [list: enum])
    end
  end
  def check(_value, _opts),
    do: error("is in the black list: %{list}", [list: ""])
end
