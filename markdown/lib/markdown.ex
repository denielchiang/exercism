defmodule Markdown do
  @doc """
  Parses a given string with Markdown syntax and returns the associated HTML for that string.

  ## Examples

  iex> Markdown.parse("This is a paragraph")
  "<p>This is a paragraph</p>"

  iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
  "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(m) do
    m
    |> String.split("\n")
    |> Enum.map(&process/1)
    |> Enum.join()
    |> patch
  end

  defp process("#" <> _ = words), do: process_header(words)
  defp process("*" <> _ = words), do: process_items(words)
  defp process(words), do: process_paragraph(words)

  defp process_header(words) do
    [h | _rest] = String.split(words)

    words
    |> String.replace(~r/^#{h}\s*/, "")
    |> wrap("h#{String.length(h)}")
  end

  defp process_items(words) do
    words
    |> String.trim_leading("* ")
    |> String.split()
    |> process_inline_md
    |> wrap("li")
  end

  defp process_paragraph(words) do
    words
    |> String.split()
    |> process_inline_md
    |> wrap("p")
  end

  defp process_inline_md(words) do
    words
    |> Enum.map(&replace_inline/1)
    |> Enum.join(" ")
  end

  defp replace_inline(w) do
    w
    |> replace_prefix_md
    |> replace_suffix_md
  end

  defp wrap(content, tag_type), do: "<#{tag_type}>#{content}</#{tag_type}>"

  defp replace_prefix_md(w) do
    w
    |> String.replace_prefix("__", "<strong>")
    |> String.replace_prefix("_", "<em>")
  end

  defp replace_suffix_md(w) do
    w
    |> String.replace_suffix("__", "</strong>")
    |> String.replace_suffix("_", "</em>")
  end

  defp patch(l) do
    l
    |> String.replace("<li>", "<ul>" <> "<li>", global: false)
    |> String.replace_suffix("</li>", "</li>" <> "</ul>")
  end
end
