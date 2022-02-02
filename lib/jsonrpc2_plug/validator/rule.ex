defmodule JSONRPC2Plug.Validator.Rule do
  @type ok :: :ok
  @type error :: {:error, String.t(), keyword()}
  @type rule :: (term() -> ok() | error())

  @callback rule(keyword()) :: rule()
  @callback check(term(), keyword()) :: ok() | error()

  defmacro __using__(_) do
    quote location: :keep do
      def rule(opts \\ []),
        do: fn(value) -> check(value, opts) end

      defoverridable [rule: 1]

      defp error(message, opts \\ []),
        do: {:error, message, opts}
    end
  end
end
