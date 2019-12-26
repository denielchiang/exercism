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

  defp process("#" <> _ = t), do: t |> parse_header_md_level |> enclose_with_header_tag
  defp process("*" <> _ = t), do: t |> parse_list_md_level
  defp process(t), do: t |> String.split() |> enclose_with_paragraph_tag

  defp parse_header_md_level(hwt) do
    [h | t] = String.split(hwt)
    {h |> String.length() |> to_string, t |> Enum.join(" ")}
  end

  defp parse_list_md_level(l) do
    t =
      l
      |> String.trim_leading("* ")
      |> String.split()

    "<li>" <> (t |> join_words_with_tags()) <> "</li>"
  end

  defp enclose_with_header_tag({hl, htl}), do: "<h" <> hl <> ">" <> htl <> "</h" <> hl <> ">"

  defp enclose_with_paragraph_tag(t), do: "<p>#{t |> join_words_with_tags()}</p>"

  defp join_words_with_tags(t), do: t |> Enum.map(&replace_md_with_tag/1) |> Enum.join(" ")

  defp replace_md_with_tag(w), do: w |> replace_prefix_md |> replace_suffix_md

  defp replace_prefix_md_strong(w),
    do: w |> String.replace(~r/^#{"__"}{1}/, "<strong>", global: false)

  defp replace_prefix_md_em(w), do: w |> String.replace(~r/_/, "<em>", global: false)

  defp replace_prefix_md(w) do
    cond do
      w =~ ~r/^#{"__"}{1}/ -> w |> replace_prefix_md_strong
      w =~ ~r/^[#{"_"}{1}][^#{"_"}+]/ -> w |> replace_prefix_md_em
      true -> w
    end
  end

  defp replace_suffix_md_string(w), do: w |> String.replace(~r/#{"__"}{1}$/, "</strong>")
  defp replace_suffix_md_em(w), do: w |> String.replace(~r/_/, "</em>")

  defp replace_suffix_md(w) do
    cond do
      w =~ ~r/#{"__"}{1}$/ -> w |> replace_suffix_md_string
      w =~ ~r/[^#{"_"}{1}]/ -> w |> replace_suffix_md_em
      true -> w
    end
  end

  defp patch(l) do
    l
    |> String.replace("<li>", "<ul>" <> "<li>", global: false)
    |> String.replace_suffix("</li>", "</li>" <> "</ul>")
  end
end
