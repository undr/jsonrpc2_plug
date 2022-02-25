defmodule JSONRPC2Plug.Validator.DatasetTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Validator.Dataset

  setup(_) do
    {:ok, valid_dataset: valid_dataset(), invalid_dataset: invalid_dataset()}
  end

  def valid_dataset(),
    do: %Dataset{data: %{"some" => "data"}, errors: []}

  def invalid_dataset() do
    %Dataset{
      data: %{"some" => "data"},
      errors: [some: [{"is required", []}, {"is not a %{type}", [type: :integer]}]]
    }
  end

  test ".wrap", %{valid_dataset: dataset} do
    assert ^dataset = Dataset.wrap(%{"some" => "data"})
    assert ^dataset = Dataset.wrap(dataset)
  end

  test ".add_error", %{valid_dataset: dataset, invalid_dataset: after_dataset} do
    dataset = dataset
    |> Dataset.add_error("some", {"is not a %{type}", [type: :integer]})
    |> Dataset.add_error("some", "is required")

    assert ^after_dataset = dataset
  end

  describe ".unwrap" do
    test "with valid dataset", %{valid_dataset: dataset} do
      assert {:ok, %{"some" => "data"}} = Dataset.unwrap(dataset)
    end

    test "with invalid dataset", %{invalid_dataset: dataset} do
      assert {:invalid, %{some: ["is required", "is not a integer"]}} = Dataset.unwrap(dataset)
    end
  end
end
