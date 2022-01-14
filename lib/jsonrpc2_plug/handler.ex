defmodule JSONRPC2Plug.Handler do
  require Logger

  alias JSONRPC2Plug.Error
  alias JSONRPC2Plug.Request
  alias JSONRPC2Plug.Response

  defmacro __using__(_) do
    quote do
      def handle(params, conn) do
        unquote(__MODULE__).handle(__MODULE__, params, conn)
      end

      def handle_notification(method, params, conn),
        do: handle_request(method, params, conn)

      def handle_request(_method, _params, _conn),
        do: error!(-32601, "Method not found")

      def handle_error(exception, stacktrace),
        do: Logger.error(Exception.format(:error, exception, stacktrace))

      defoverridable [handle_request: 3, handle_error: 2, handle_notification: 3]

      defp error!(code, message),
        do: throw {:jsonrpc2, code, message}
      defp error!(code, message, data),
        do: throw {:jsonrpc2, code, message, data}
    end
  end

  @doc false
  def handle(module, data, conn) when is_list(data),
    do: data |> Request.parse() |> handle_batch(module, conn)
  def handle(module, data, conn),
    do: data |> Request.parse() |> handle_one(module, conn)

  defp handle_batch(data, module, conn),
    do: Enum.map(data, fn(tuple) -> handle_one(tuple, module, conn) end) |> Enum.reject(&is_nil/1)

  defp handle_one(%Error{} = error, _module, _conn),
    do: error
  defp handle_one(%Request{} = request, module, conn) do
    if Request.valid?(request) do
      dispatch(module, request, conn)
    else
      Error.error(:invalid_request, request.id)
    end
  end

  defp dispatch(module, %{id: nil, method: method, params: params}, conn) do
    try do
      module.handle_notification(method, params, conn)
      nil
    rescue
      ex ->
        module.handle_error(ex, __STACKTRACE__)
    catch
      :throw, {:jsonrpc2, code, message} when is_integer(code) and is_binary(message) ->
        nil

      :throw, {:jsonrpc2, code, message, data} when is_integer(code) and is_binary(message) ->
        nil

      kind, payload ->
        Logger.error([
          "Error in handler ", inspect(module), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(kind, payload, __STACKTRACE__)
        ])

        nil
    end
  end
  defp dispatch(module, %{id: id, method: method, params: params}, conn) do
    try do
      method
      |> module.handle_request(params, conn)
      |> Response.new(id)
    rescue
      ex ->
        module.handle_error(ex, __STACKTRACE__)
    catch
      :throw, {:jsonrpc2, code, message} when is_integer(code) and is_binary(message) ->
        Error.new(id, code, message)

      :throw, {:jsonrpc2, code, message, data} when is_integer(code) and is_binary(message) ->
        Error.new(id, code, message, data)

      kind, payload ->
        Logger.error([
          "Error in handler ", inspect(module), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(kind, payload, __STACKTRACE__)
        ])

        Error.error(:internal_error, id)
    end
  end

  defp dispatch(_module, _data, _conn),
    do: Error.error(:invalid_request, nil)
end
