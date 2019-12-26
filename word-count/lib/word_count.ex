defmodule WordCount do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @regular ~r/[^\p{L}0-9\-]/u
  @spec count(String.t()) :: map
  def count(sentence) do
    sentence
    |> String.replace(@regular, " ")
    |> String.downcase()
    |> String.split()
    |> Enum.reduce(%{}, &trans_map/2)
  end

  defp trans_map(elem, acc),
    do: Map.update(acc, elem, 1, &(&1 + 1))
end
