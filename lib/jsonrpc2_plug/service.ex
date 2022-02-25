defmodule JSONRPC2Plug.Service do
  require Logger

  alias JSONRPC2Plug.Error
  alias JSONRPC2Plug.Request
  alias JSONRPC2Plug.Response

  defmacro __using__(_) do
    quote location: :keep do
      @__service_methods__ []

      Module.register_attribute(__MODULE__, :__service_methods__, accumulate: true)

      import unquote(__MODULE__), only: [method: 2]

      @before_compile unquote(__MODULE__)

      def handle(%{"_json" => body_params}, conn) when is_list(body_params),
        do: Enum.map(body_params, fn(one) -> handle_one(one, conn) end) |> drop_nils()
      def handle(body_params, conn) when is_map(body_params),
        do: handle_one(body_params, conn)

      defp handle_one(body_params, conn) do
        with {:ok, request} <- Request.parse(body_params) do
          with :ok <- Request.valid?(request),
               {:ok, handler} <- handler_lookup(request.method),
               {:ok, result} <- exec_handler(handler, request, conn) do
            response(request.id, result)
          else
            {:jsonrpc2_error, code_or_tuple} ->
              error(request.id, code_or_tuple)

            {:error, error} ->
              error(request.id, {:internal_error, inspect(error)})

            :error ->
              error(request.id, {:method_not_found, inspect(request.method)})

            :invalid ->
              error(request.id, :invalid_request)

            error ->
              error(request.id, {:internal_error, inspect(error)})
          end
        else
          {:invalid, id} ->
            error(id, :invalid_request)

          error ->
            error
        end
      end

      defp handler_lookup(name) do
        Keyword.fetch(__service_methods__(), String.to_atom(name))
      end

      defp exec_handler(handler, %Request{id: id, method: method, params: params} = request, conn) do
        try do
          if is_nil(id) do
            handler.cast(params, conn)
          else
            handler.call(params, conn)
          end
        rescue
          exception ->
            handler.handle_exception(request, exception, __STACKTRACE__)
        catch
          :throw, {:jsonrpc2_error, code_or_tuple} ->
            {:jsonrpc2_error, code_or_tuple}

          kind, payload ->
            handler.handle_error(request, {kind, payload}, __STACKTRACE__)
        end
      end

      defp drop_nils(responses),
        do: Enum.reject(responses, &is_nil/1)

      defp response(nil, _result),
        do: nil
      defp response(id, result),
        do: Response.new(id, result)

      defp error(nil, _),
        do: nil
      defp error(id, {code, message_or_data}),
        do: Error.new(id, code, message_or_data)
      defp error(id, {code, message, data}),
        do: Error.new(id, code, message, data)
      defp error(id, code),
        do: Error.new(id, code)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      def __service_methods__,
        do: @__service_methods__
    end
  end

  @spec method(Request.method(), module()) :: term()
  defmacro method(name, handler) when is_binary(name),
    do: build_method(String.to_atom(name), handler)

  @spec method(atom(), module()) :: term()
  defmacro method(name, handler) when is_atom(name),
    do: build_method(name, handler)

  defp build_method(name, handler) do
    quote location: :keep do
      @__service_methods__ {unquote(name), unquote(handler)}
    end
  end
end
