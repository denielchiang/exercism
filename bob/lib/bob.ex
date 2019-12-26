defmodule Bob do
  def hey(input) do
    cond do
      nonsense?(input) ->
        "Fine. Be that way!"

      yell_question?(input) ->
        "Calm down, I know what I'm doing!"

      yell?(input) ->
        "Whoa, chill out!"

      question?(input) ->
        "Sure."

      true ->
        "Whatever."
    end
  end

  defp nonsense?(input), do: input |> String.trim() |> String.length() == 0

  defp yell_question?(input),
    do: question?(input) and yell?(input)

  defp yell?(input), do: input |> String.upcase() == input and input =~ ~r/[[:alpha:]]/
  defp question?(input), do: input |> String.trim() |> String.ends_with?("?")
end
