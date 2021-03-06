defmodule JSONRPC2Plug.Validator.Rule do
  @type ok :: :ok
  @type error :: {:error, String.t(), keyword()}
  @type rule :: (term() -> ok() | error())
  @type result :: :ok | error()
  @type value :: nil | term()
  @type opts :: keyword()

  @callback rule(keyword()) :: rule()
  @callback check(term(), keyword()) :: ok() | error()

  defmacro __using__(_) do
    quote location: :keep do
      def rule(opts \\ []) do
        fn
          (nil)   -> :ok
          (value) -> check(value, opts)
        end
      end

      defoverridable [rule: 1]

      defp error(message, opts \\ []),
        do: {:error, message, opts}
    end
  end
end
