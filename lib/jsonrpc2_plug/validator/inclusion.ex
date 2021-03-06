defmodule JSONRPC2Plug.Validator.Inclusion do
  alias JSONRPC2Plug.Validator.Rule

  use JSONRPC2Plug.Validator.Rule

  @spec check(Rule.value(), Rule.opts()) :: Rule.result()
  def check(nil, _opts),
    do: :ok
  def check(value, [{:in, enum}]) do
    if Enumerable.impl_for(enum) do
      if Enum.member?(enum, value) do
        :ok
      else
        error("is not in the inclusion list: %{list}", [list: Enum.join(enum, ", ")])
      end
    else
      error("is not in the inclusion list: %{list}", [list: enum])
    end
  end
  def check(_value, _opts),
    do: error("is not in the inclusion list: %{list}", [list: ""])
end
