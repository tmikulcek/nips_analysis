defmodule NipsAnalysis do
  use Cesso

  def generate_reference_list(file) do
    CSV.decode(File.stream!(file), columns: true)
      |> Enum.flat_map(&extract_references/1)
      |> Enum.map(&extract_authors/1)
  end

  defp extract_references(row) do
    Enum.filter_map(row, &take_text/1, &(elem(&1, 1)))
      |> hd
      |> scan_for_references
      |> Enum.drop_while(fn match_list -> !String.starts_with?(hd(match_list), "[1]") end)
      |> Enum.map(&format_match/1)
  end

  defp extract_authors(reference) do
    Regex.scan(~r/^(.+?)\. [A-Z][^.]/, reference)
  end

  defp take_text(tuple) do
    case tuple do
      {"PaperText\n", _} -> true
      _ -> false
    end
  end

  defp scan_for_references(text) do
    Regex.scan(~r/^\[[0-9]+?\] ([^\[]+)/ms, text)
  end

  defp format_match(match_list) do
    Enum.at(match_list, 1)
      |> String.replace("\n\n", " ")
      |> String.strip
  end
end
