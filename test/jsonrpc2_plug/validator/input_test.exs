defmodule JSONRPC2Plug.Validator.InputTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Validator.Input

  setup(_) do
    {:ok, valid_input: valid_input(), invalid_input: invalid_input()}
  end

  def valid_input(),
    do: %Input{data: %{"some" => "data"}, errors: []}

  def invalid_input() do
    %Input{
      data: %{"some" => "data"},
      errors: [some: [{"is required", []}, {"is not a %{type}", [type: :integer]}]]
    }
  end

  test ".wrap", %{valid_input: input} do
    assert ^input = Input.wrap(%{"some" => "data"})
    assert ^input = Input.wrap(input)
  end

  test ".add_error", %{valid_input: input, invalid_input: after_input} do
    input = input
    |> Input.add_error("some", {"is not a %{type}", [type: :integer]})
    |> Input.add_error("some", "is required")

    assert ^after_input = input
  end

  describe ".unwrap" do
    @tag valid: true
    test "with valid input", %{valid_input: input} do
      assert {:ok, %{"some" => "data"}} = Input.unwrap(input)
    end

    test "with invalid input", %{invalid_input: input} do
      assert {:invalid, [some: ["is required", "is not a integer"]]} = Input.unwrap(input)
    end
  end
end
