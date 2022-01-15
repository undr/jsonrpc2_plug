defmodule JSONRPC2Plug.RequestTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Request

  setup(context) do
    request_opts = context[:request] || []
    {:ok, request: struct(Request, Keyword.merge([id: 123, method: "test.method", params: [1, 2]], request_opts))}
  end

  test ".parse", %{request: request} do
    assert {:invalid, nil} = Request.parse(nil)
    assert {:invalid, nil} = Request.parse(%{})
    assert {:invalid, 123} = Request.parse(%{"id" => 123, "method" => "test.method", "params" => [1, 2]})
    assert {:ok, ^request} = Request.parse(%{"id" => 123, "method" => "test.method", "params" => [1, 2], "jsonrpc" => "2.0"})
  end

  describe ".valid?" do
    test "with valid request", %{request: request} do
      assert :ok = Request.valid?(request)
    end

    @tag request: [method: 321]
    test "with invalid method", %{request: request} do
      assert :invalid = Request.valid?(request)
    end

    @tag request: [params: 123]
    test "with invalid params", %{request: request} do
      assert :invalid = Request.valid?(request)
    end
  end
end
