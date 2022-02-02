defmodule JSONRPC2Plug.Method do
  @callback handle_call(map() | list(), Plug.Conn.t()) :: {:ok, any()} | {:error, any()} | {:jsonrpc2_error, any()}
  @callback handle_cast(map() | list(), Plug.Conn.t()) :: {:ok, any()} | {:error, any()} | {:jsonrpc2_error, any()}
  @callback validate(map() | list()) :: {:ok, map() | list()} | {:invalid, keyword() | map()}
  @callback handle_exception(map(), Exception.t(), list()) :: {:jsonrpc2_error, any()}
  @callback handle_error(map(), {Exception.kind(), any()}, list()) :: {:jsonrpc2_error, any()}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      require Logger

      alias JSONRPC2Plug.Request

      def call(params, conn),
        do: unquote(__MODULE__).handle({__MODULE__, :handle_call}, params, conn)

      def cast(params, conn),
        do: unquote(__MODULE__).handle({__MODULE__, :handle_cast}, params, conn)

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

      defp log_error(%Request{method: method, params: params}, {kind, payload}, stacktrace) do
        Logger.error([
          "Error in handler ", inspect(__MODULE__), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(kind, payload, stacktrace)
        ])
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep, generated: true do
      def handle_call(params, conn),
        do: error(:invalid_params)

      def handle_cast(params, conn),
        do: handle_call(params, conn)

      def validate(params),
        do: {:ok, params}

      def handle_exception(request, ex, stacktrace) do
        log_error(request, {:error, ex}, stacktrace)
        {:jsonrpc2_error, {:server_error, [ex: inspect(ex), message: Exception.format(:error, ex, stacktrace)]}}
      end

      def handle_error(request, {kind, payload}, stacktrace) do
        log_error(request, {kind, payload}, stacktrace)
        {:jsonrpc2_error, {:internal_error, [kind: inspect(kind), payload: inspect(payload)]}}
      end
    end
  end

  def handle({module, func}, params, conn) do
    with {:ok, params} <- module.validate(params),
         {:ok, result} <- apply(module, func, [params, conn]) do
      {:ok, result}
    else
      {:invalid, errors} ->
        {:jsonrpc2_error, {:invalid_params, Enum.into(errors, %{})}}

      error ->
        error
    end
  end
end
