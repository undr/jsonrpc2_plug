defmodule JSONRPC2Plug.Validator.Exclusion do
  use JSONRPC2Plug.Validator.Rule

  def check(nil, _opts), 
    do: :ok
  def check(value, [{:in, enum}]) do
    if Enumerable.impl_for(enum) && !Enum.member?(enum, value) do
      :ok
    else
      error("is in the black list: %{list}", [list: enum])
    end
  end
  def check(_value, _opts),
    do: error("is in the black list: %{list}", [list: []])
end
