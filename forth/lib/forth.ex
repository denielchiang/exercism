defmodule Forth do
  defstruct stk: []
  @opaque evaluator :: %Forth{}

  @non_word_reg ~r/[\pC\pZ]+/u
  @digit_reg ~r/^[[:digit:]]+$/
  @dictionary [:+, :-, :*, :/]

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new(), do: %Forth{stk: [], dict: @dictionary}

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(ev, s) do
    s
    |> String.split(@non_word_reg)
    |> Enum.map(&cast_integer/1)
    |> parse(ev)
  end

  defp cast_integer(token), do: check_type(token |> String.match?(@digit_reg), token)
  defp check_type(true, token), do: token |> String.to_integer()
  defp check_type(false, token), do: token

  defp parse([], ev), do: %{ev | stk: ev.stk |> Enum.reverse()}
  defp parse([h | t], ev) when is_integer(h), do: parse(t, h |> push(ev))

  defp push(int, %Forth{stk: stack} = ev), do: %{ev | stk: [int | stack]}

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(ev) do
    ev.stk
    |> Enum.join(" ")
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
