defmodule JSONRPC2Plug do
  @behaviour Plug
  require Logger

  @impl true
  @spec init(module()) :: module()
  def init(handler),
    do: handler

  @impl true
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(%{method: "POST", body_params: %Plug.Conn.Unfetched{}}, _handler),
    do: raise "Plug the JSONRPC2Plug after Plug.Parsers"
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
  def call(conn, _),
    do: Plug.Conn.resp(conn, 404, "")

  @spec send_error(Plug.Conn.t(), atom(), struct()) :: Plug.Conn.t()
  def send_error(conn, :error, %Plug.Parsers.ParseError{} = ex),
    do: send_error_response(conn, :parse_error, Exception.message(ex))
  def send_error(conn, kind, reason) do
    details =
      case kind do
        :error -> Exception.message(reason)
        any    -> inspect(any)
      end

    send_error_response(conn, :internal_error, details)
  end

  defp send_error_response(conn, code, details) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(500, error(code, details))
  end

  defp error(code, details),
    do: JSONRPC2Plug.Error.new(nil, code, details) |> Poison.encode!()

  defp execute_request(handler, body_params, conn) do
    case handler.handle(body_params, conn) do
      []   -> ""
      nil  -> ""
      resp -> Poison.encode!(resp)
    end
  end
end
