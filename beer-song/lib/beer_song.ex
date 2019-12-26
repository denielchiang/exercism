defmodule BeerSong do
  @doc """
  Get a single verse of the beer song
  """
  @spec verse(integer) :: String.t()
  def verse(number), do: number |> combine

  defp combine(number) do
    """
    #{number |> bottle} of beer on the wall, #{number |> bottle |> String.downcase()} of beer.
    #{number |> action}, #{number |> remain} of beer on the wall.
    """
  end

  defp bottle(0), do: "No more bottles"
  defp bottle(1), do: "1 bottle"
  defp bottle(number), do: "#{number} bottles"
  defp action(0), do: "Go to the store and buy some more"
  defp action(1), do: "Take it down and pass it around"
  defp action(_number), do: "Take one down and pass it around"
  defp remain(0), do: "99 bottles"
  defp remain(1), do: "no more bottles"
  defp remain(2), do: "1 bottle"
  defp remain(number), do: "#{number - 1} bottles"

  @doc """
  Get the entire beer song for a given range of numbers of bottles.
  """
  @spec lyrics(Range.t()) :: String.t()
  def lyrics(range \\ 99..0) do
    range
    |> Enum.map_join("\n", &verse/1)
  end
end
