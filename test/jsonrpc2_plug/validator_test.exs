defmodule JSONRPC2Plug.ValidatorTest do
  use ExUnit.Case

  alias JSONRPC2Plug.Validator
  alias JSONRPC2Plug.Validator.Dataset

  setup(_) do
    {:ok, validators: [Validator.required(), Validator.len(min: 5)]}
  end

  test ".required" do
    assert {:error, "is required", []} = Validator.required().(nil)
    assert :ok = Validator.required().(%{})
    assert :ok = Validator.required().([])
    assert :ok = Validator.required().("")
    assert :ok = Validator.required().("something")
  end

  test ".not_empty" do
    assert {:error, "is empty", []} = Validator.not_empty().(%{})
    assert {:error, "is empty", []} = Validator.not_empty().([])
    assert {:error, "is empty", []} = Validator.not_empty().("")
    assert :ok = Validator.not_empty().("something")
    assert :ok = Validator.not_empty().(nil)
  end

  test ".format" do
    assert {:error, "does not match format %{format}", [format: ~r/some/]} = Validator.format(~r/some/).("xxx")
    assert {:error, "does not match format %{format}", [format: ~r/some/]} = Validator.format(~r/some/).(123)
    assert :ok = Validator.format(~r/some/).(nil)
    assert :ok = Validator.format(~r/some/).("something")
  end

  test ".exclude" do
    assert {:error, "is in the black list: %{list}", [list: [1, 2, 3]]} = Validator.exclude([1, 2, 3]).(2)
    assert {:error, "is in the black list: %{list}", [list: "123"]} = Validator.exclude("123").("4")
    assert {:error, "is in the black list: %{list}", [list: 12345]} = Validator.exclude(12345).(2)
    assert :ok = Validator.exclude([1, 2, 3]).(4)
    assert :ok = Validator.exclude([1, 2, 3]).(nil)
  end

  test ".include" do
    assert {:error, "is not in the inclusion list: %{list}", [list: [1, 2, 3]]} = Validator.include([1, 2, 3]).(4)
    assert {:error, "is not in the inclusion list: %{list}", [list: "123"]} = Validator.include("123").("3")
    assert {:error, "is not in the inclusion list: %{list}", [list: 12345]} = Validator.include(12345).(2)
    assert :ok = Validator.include([1, 2, 3]).(3)
    assert :ok = Validator.include([1, 2, 3]).(nil)
  end

  test ".number" do
    assert {:error, "must be equal to %{value}", [value: 3]} = Validator.number(equal_to: 3).(2)
    assert :ok = Validator.number(equal_to: 3).(3)
    assert {:error, "must be greater than or equal to %{value}", [value: 3]} = Validator.number(gte: 3).(2)
    assert :ok = Validator.number(gte: 3).(3)
    assert {:error, "must be greater than or equal to %{value}", [value: 3]} = Validator.number(min: 3).(2)
    assert :ok = Validator.number(min: 3).(3)
    assert {:error, "must be greater than %{value}", [value: 2]} = Validator.number(gt: 2).(2)
    assert :ok = Validator.number(gt: 2).(3)
    assert {:error, "must be less than or equal to %{value}", [value: 2]} = Validator.number(lte: 2).(3)
    assert :ok = Validator.number(lte: 2).(2)
    assert {:error, "must be less than or equal to %{value}", [value: 2]} = Validator.number(max: 2).(3)
    assert :ok = Validator.number(max: 2).(2)
    assert {:error, "must be less than %{value}", [value: 2]} = Validator.number(lt: 2).(2)
    assert :ok = Validator.number(lt: 2).(1)

    assert {:error, "unknown rule '%{rule}'", rule: :xx} = Validator.number(xx: 2).(123)
  end

  test ".len" do
    assert {:error, "length must be equal to %{value}", [value: 3]} = Validator.len(equal_to: 3).([1, 2])
    assert :ok = Validator.len(equal_to: 3).([1, 2, 3])
    assert {:error, "length must be greater than or equal to %{value}", [value: 3]} = Validator.len(gte: 3).([1, 2])
    assert :ok = Validator.len(gte: 3).([1, 2, 3])
    assert {:error, "length must be greater than or equal to %{value}", [value: 3]} = Validator.len(min: 3).([1, 2])
    assert :ok = Validator.len(min: 3).([1, 2, 3])
    assert {:error, "length must be greater than %{value}", [value: 2]} = Validator.len(gt: 2).([1, 2])
    assert :ok = Validator.len(gt: 2).([1, 2, 3])
    assert {:error, "length must be less than or equal to %{value}", [value: 2]} = Validator.len(lte: 2).([1, 2, 3])
    assert :ok = Validator.len(lte: 2).([1, 2])
    assert {:error, "length must be less than or equal to %{value}", [value: 2]} = Validator.len(max: 2).([1, 2, 3])
    assert :ok = Validator.len(max: 2).([1, 2])
    assert {:error, "length must be less than %{value}", [value: 2]} = Validator.len(lt: 2).([1, 2])
    assert :ok = Validator.len(lt: 2).([1])

    assert {:error, "length must be equal to %{value}", [value: 3]} = Validator.len(equal_to: 3).("ab")
    assert :ok = Validator.len(equal_to: 3).("abc")
    assert {:error, "length must be greater than or equal to %{value}", [value: 3]} = Validator.len(gte: 3).("ab")
    assert :ok = Validator.len(gte: 3).("abc")
    assert {:error, "length must be greater than or equal to %{value}", [value: 3]} = Validator.len(min: 3).("ab")
    assert :ok = Validator.len(min: 3).("abc")
    assert {:error, "length must be greater than %{value}", [value: 2]} = Validator.len(gt: 2).("ab")
    assert :ok = Validator.len(gt: 2).("abc")
    assert {:error, "length must be less than or equal to %{value}", [value: 2]} = Validator.len(lte: 2).("abc")
    assert :ok = Validator.len(lte: 2).("ab")
    assert {:error, "length must be less than or equal to %{value}", [value: 2]} = Validator.len(max: 2).("abc")
    assert :ok = Validator.len(max: 2).("ab")
    assert {:error, "length must be less than %{value}", [value: 2]} = Validator.len(lt: 2).("ab")
    assert :ok = Validator.len(lt: 2).("a")

    assert {:error, "length check supports only arrays, strings and objects", []} = Validator.len(lt: 2).(123)
  end

  test ".type" do
    Enum.each(~w[boolean integer float number string array object]a, fn(type) ->
      assert :ok = Validator.type(type).(nil)
    end)

    # boolean
    assert {:error, "is not a %{type}", [type: :boolean]} = Validator.type(:boolean).([1, 2])
    assert :ok = Validator.type(:boolean).(true)
    assert :ok = Validator.type(:boolean).(false)
    # integer
    assert {:error, "is not a %{type}", [type: :integer]} = Validator.type(:integer).("blah blah")
    assert {:error, "is not a %{type}", [type: :integer]} = Validator.type(:integer).(12.34)
    assert :ok = Validator.type(:integer).(1234)
    assert :ok = Validator.type(:integer).(-1234)
    # float
    assert {:error, "is not a %{type}", [type: :float]} = Validator.type(:float).("blah blah")
    assert {:error, "is not a %{type}", [type: :float]} = Validator.type(:float).(1234)
    assert :ok = Validator.type(:float).(12.34)
    assert :ok = Validator.type(:float).(-12.34)
    # number
    assert {:error, "is not a %{type}", [type: :number]} = Validator.type(:number).("blah blah")
    assert :ok = Validator.type(:number).(1234)
    assert :ok = Validator.type(:number).(-1234)
    assert :ok = Validator.type(:number).(12.34)
    assert :ok = Validator.type(:number).(-12.34)
    # string
    assert {:error, "is not a %{type}", [type: :string]} = Validator.type(:string).(123)
    assert {:error, "is not a %{type}", [type: :string]} = Validator.type(:string).([1, 2, 3])
    assert :ok = Validator.type(:string).("1234")
    assert :ok = Validator.type(:string).("blah blah")
    # object
    assert {:error, "is not a %{type}", [type: :object]} = Validator.type(:object).(123)
    assert {:error, "is not a %{type}", [type: :object]} = Validator.type(:object).([1, 2, 3])
    assert :ok = Validator.type(:object).(%{})
    assert :ok = Validator.type(:object).(%{"some" => "value"})
    # array
    assert {:error, "is not a %{type}", [type: :array]} = Validator.type(:array).(123)
    assert {:error, "is not a %{type}", [type: :array]} = Validator.type(:array).("blah blah")
    assert :ok = Validator.type(:array).('blah blah')
    assert :ok = Validator.type(:array).([1, "2", 3])
    assert :ok = Validator.type(:array).([1, 2, 3])
    assert :ok = Validator.type(:array).([])
    # array, type
    type = {:array, :float}
    assert {:error, "is not a %{type}", [type: :array]} = Validator.type(type).(123)
    assert {:error, "is not a %{type}", [type: :array]} = Validator.type(type).("blah")
    assert {:error, "content is not a %{type}", [type: :float]} = Validator.type(type).([1])
    assert {:error, "content is not a %{type}", [type: :float]} = Validator.type(type).([1, "2"])
    assert :ok = Validator.type(type).([1.01, 1.03, 1.05])
    assert :ok = Validator.type(type).([])
  end

  describe ".validate" do
    test "with data", %{validators: validators} do
      assert %Dataset{errors: []} = Validator.validate(%{"some" => "value"}, "some", validators)
      assert %Dataset{
        errors: [some: [{"length must be greater than or equal to %{value}", [value: 5]}]]
      } = Validator.validate(%{"some" => "data"}, "some", validators)
    end

    test "with dataset", %{validators: validators} do
      assert %Dataset{
        errors: []
      } = Validator.validate(Dataset.wrap(%{"some" => "value"}), "some", validators)

      assert %Dataset{
        errors: [some: [{"length must be greater than or equal to %{value}", [value: 5]}]]
      } = Validator.validate(Dataset.wrap(%{"some" => "data"}), "some", validators)
    end
  end

  describe ".unwrap" do
    test "with valid dataset" do
      dataset = %Dataset{data: %{"some" => "value"}}
      assert {:ok, %{"some" => "value"}} = Validator.unwrap(dataset)
    end

    test "with invalid dataset" do
      dataset = %Dataset{
        data: %{"some" => "value"},
        errors: [some: [{"is not a %{type}", [type: :integer]}, {"is required", []}]]
      }

      assert {:invalid, %{some: ["is not a integer", "is required"]}} = Validator.unwrap(dataset)
    end
  end
end
