defmodule JSONRPC2Plug.ErrorTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Error

  test ".code2error" do
    assert {-32700, "Parse error"} = Error.code2error(:parse_error)
    assert {-32600, "Invalid request"} = Error.code2error(:invalid_request)
    assert {-32601, "Method not found"} = Error.code2error(:method_not_found)
    assert {-32602, "Invalid params"} = Error.code2error(:invalid_params)
    assert {-32603, "Internal error"} = Error.code2error(:internal_error)
    assert {-32603, "Internal error"} = Error.code2error(:unknown_error)
  end
end
