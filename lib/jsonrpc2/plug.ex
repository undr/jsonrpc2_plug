defmodule JSONRPC2.Plug do
  @moduledoc "README.md" |> File.read!()

  @behaviour Plug
  require Logger

  @impl true
  @spec init(module()) :: module()
  def init(handler) do
    handler
  end

  @doc """
  HTTP entry point to JSONRPC 2.0 services. It's usual plug and accepts service handler module as a param.

  Example:
      use Plug.Router

      forward "/jsonrpc", to: JSONRPC2.Plug, init_opts: CalculatorService
  """
  @impl true
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(%{method: "POST", body_params: %Plug.Conn.Unfetched{}}, _handler) do
    raise "Plug the JSONRPC2.Plug after Plug.Parsers"
  end

  @impl true
  def call(%{method: "POST", body_params: body_params} = conn, handler) do
    Logger.debug("JSONRPC2 Request: #{inspect(body_params)}")

    response = execute_request(handler, body_params, conn)

    Logger.debug("JSONRPC2 Response: #{response}")

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(200, response)
  end

  @impl true
  def call(conn, _) do
    Plug.Conn.resp(conn, 404, "")
  end

  @doc """
  Send an error encoded according to JSONRPC 2.0 spec. It can be useful for global error handler in the router.

  Example:
      forward "/jsonrpc", to: JSONRPC2.Plug, init_opts: CalculatorService

      @impl Plug.ErrorHandler
      def handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
        Logger.error(Exception.format(kind, reason, stacktrace))

        case conn do
          %{request_path: "/jsonrpc"} ->
            JSONRPC2.Plug.send_error(conn, kind, reason)

          _ ->
            send_resp(conn, 500, "Someting went wrong")
        end
      end
  """
  @spec send_error(Plug.Conn.t(), atom(), struct()) :: Plug.Conn.t()
  def send_error(conn, :error, %Plug.Parsers.ParseError{} = ex) do
    send_error_response(conn, :parse_error, Exception.message(ex))
  end

  def send_error(conn, kind, reason) do
    details =
      case kind do
        :error ->
          Exception.message(reason)

        any ->
          inspect(any)
      end

    send_error_response(conn, :internal_error, details)
  end

  defp send_error_response(conn, code, details) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(500, error(code, details))
  end

  defp error(code, details) do
    nil |> JSONRPC2.Spec.Error.new(code, details) |> JSON.encode!()
  end

  defp execute_request(handler, body_params, conn) do
    case handler.handle(body_params, conn) do
      [] ->
        ""

      nil ->
        ""

      resp ->
        JSON.encode!(resp)
    end
  end
end
