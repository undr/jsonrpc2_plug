defmodule JSONRPC2Plug.ErrorTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Error

  describe ".error" do
    test "Parse error" do
      assert %Error{id: 123, error: %{code: -32700, message: "Parse error"}} = Error.error(:parse_error, 123)
      assert %Error{id: nil, error: %{code: -32700, message: "Parse error"}} = Error.error(:parse_error)
    end

    test "Invalid Request" do
      assert %Error{id: 123, error: %{code: -32600, message: "Invalid Request"}} = Error.error(:invalid_request, 123)
      assert %Error{id: nil, error: %{code: -32600, message: "Invalid Request"}} = Error.error(:invalid_request)
    end

    test "Method not found" do
      assert %Error{id: 123, error: %{code: -32601, message: "Method not found"}} = Error.error(:method_not_found, 123)
      assert %Error{id: nil, error: %{code: -32601, message: "Method not found"}} = Error.error(:method_not_found)
    end

    test "Invalid params" do
      assert %Error{id: 123, error: %{code: -32602, message: "Invalid params"}} = Error.error(:invalid_params, 123)
      assert %Error{id: nil, error: %{code: -32602, message: "Invalid params"}} = Error.error(:invalid_params)
    end

    test "Internal error" do
      assert %Error{id: 123, error: %{code: -32603, message: "Internal error"}} = Error.error(:internal_error, 123)
      assert %Error{id: nil, error: %{code: -32603, message: "Internal error"}} = Error.error(:internal_error)
    end

    test "Server error" do
      assert %Error{id: 123, error: %{code: -32000, message: "Server error"}} = Error.error(:server_error, 123)
      assert %Error{id: nil, error: %{code: -32000, message: "Server error"}} = Error.error(:server_error)
    end
  end
end
