defmodule JSONRPC2Plug.Method do
  defmacro __using__(_) do
    quote location: :keep do
      require Logger

      alias JSONRPC2Plug.Request

      def call(params, conn) do
        unquote(__MODULE__).handle({__MODULE__, :handle_call}, params, conn)
      end

      def cast(params, conn) do
        unquote(__MODULE__).handle({__MODULE__, :handle_cast}, params, conn)
      end

      def handle_call(params, conn),
        do: error(:invalid_params)

      def handle_cast(params, conn),
        do: handle_call(params, conn)

      def validate(params, _conn),
        do: {:ok, params}

      def handle_exception(%Request{method: method, params: params}, ex, stacktrace) do
        Logger.error([
          "Error in handler ", inspect(__MODULE__), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(:error, ex, stacktrace)
        ])

        {:jsonrpc2_error, {:server_error, [ex: inspect(ex), message: Exception.format(:error, ex, stacktrace)]}}
      end

      def handle_error(%Request{method: method, params: params}, {kind, payload}, stacktrace) do
        Logger.error([
          "Error in handler ", inspect(__MODULE__), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(kind, payload, stacktrace)
        ])

        {:jsonrpc2_error, {:internal_error, [kind: inspect(kind), payload: inspect(payload)]}}
      end

      defoverridable [
        handle_call: 2,
        handle_cast: 2,
        validate: 2,
        handle_error: 3,
        handle_exception: 3
      ]

      defp error!(code),
        do: throw error(code)
      defp error!(code, message_or_data),
        do: throw error(code, message_or_data)
      defp error!(code, message, data),
        do: throw error(code, message, data)

      defp error(code),
        do: {:jsonrpc2_error, code}
      defp error(code, message_or_data),
        do: {:jsonrpc2_error, {code, message_or_data}}
      defp error(code, message, data),
        do: {:jsonrpc2_error, {code, message, data}}
    end
  end

  def handle({module, func}, params, conn) do
    with {:ok, params} <- module.validate(params, conn),
         {:ok, result} <- apply(module, func, [params, conn]) do
      {:ok, result}
    else
      {:invalid, details} ->
        {:jsonrpc2_error, {:invalid_params, Enum.into(details, %{})}}

      error ->
        error
    end
  end
end
