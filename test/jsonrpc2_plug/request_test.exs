defmodule JSONRPC2Plug.RequestTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Error
  alias JSONRPC2Plug.Request

  describe ".parse" do
    test "batch" do
      assert %Error{id: nil, error: %{code: -32600, message: "Invalid Request"}} = Request.parse([])

      example = [
        %Error{id: 123, error: %{code: -32600, message: "Invalid Request"}},
        %Request{id: 123, method: "test.method", params: [1, 2]}
      ]

      assert ^example = Request.parse([
        %{"id" => 123},
        %{"id" => 123, "method" => "test.method", "params" => [1, 2], "jsonrpc" => "2.0"}
      ])
    end

    test "one request" do
      assert %Error{id: nil, error: %{code: -32600, message: "Invalid Request"}} = Request.parse(%{})
      assert %Error{id: 123, error: %{code: -32600, message: "Invalid Request"}} = Request.parse(%{"id" => 123})
      assert %Request{id: 123, method: "test.method", params: [1, 2]} = Request.parse(%{
        "id" => 123, "method" => "test.method", "params" => [1, 2], "jsonrpc" => "2.0"
      })
      assert %Request{id: 123, method: "test.method", params: %{"k1" => "v1"}} = Request.parse(%{
        "id" => 123, "method" => "test.method", "params" => %{"k1" => "v1"}, "jsonrpc" => "2.0"
      })
    end
  end
end
