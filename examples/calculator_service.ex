defmodule CalculatorService do
  use JSONRPC2Plug.Service

  method "add", AddMethod
  method "subtract", SubtractMethod
  method "multiply", MultiplyMethod
  method "divide", DivideMethod
end
