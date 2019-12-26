defmodule RomanNumerals do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()

  def numeral(number), do: trans_roman(number) |> List.to_string()

  defp trans_roman(0), do: ""
  defp trans_roman(number) when number >= 1000, do: [?M | trans_roman(number - 1000)]

  defp trans_roman(number) when number >= 100,
    do: digit(div(number, 100), ?C, ?D, ?M) ++ trans_roman(rem(number, 100))

  defp trans_roman(number) when number >= 10,
    do: digit(div(number, 10), ?X, ?L, ?C) ++ trans_roman(rem(number, 10))

  defp trans_roman(number) when number >= 1, do: digit(number, ?I, ?V, ?X)

  defp digit(1, x, _, _), do: [x]
  defp digit(2, x, _, _), do: [x, x]
  defp digit(3, x, _, _), do: [x, x, x]
  defp digit(4, x, y, _), do: [x, y]
  defp digit(5, _, y, _), do: [y]
  defp digit(6, x, y, _), do: [y, x]
  defp digit(7, x, y, _), do: [y, x, x]
  defp digit(8, x, y, _), do: [y, x, x, x]
  defp digit(9, x, _, z), do: [x, z]
end
