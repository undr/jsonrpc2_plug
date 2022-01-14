defmodule JSONRPC2Plug do
  def init(handler),
    do: handler

  @doc false
  def call(%{method: "POST", body_params: %Plug.Conn.Unfetched{}}, _handler),
    do: raise "Plug the JSONRPC2Plug after Plug.Parsers"

  def call(%{method: "POST", body_params: body_params} = conn, handler) do
    resp_body = case handler.handle(body_params, conn) do
      []   -> ""
      nil  -> ""
      resp -> Poison.encode!(resp)
    end

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(200, resp_body)
  end

  def call(conn, _),
    do: Plug.Conn.resp(conn, 404, "")
end
