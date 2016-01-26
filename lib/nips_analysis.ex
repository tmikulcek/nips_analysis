defmodule NipsAnalysis do
  use Cesso

  def generate_reference_list(file) do
    CSV.decode(File.stream!(file), columns: true)
      |> Enum.map(&extract_references/1)
      |> Enum.reject(fn tuple -> elem(tuple, 2) == :none end)
      #|> Enum.count
      #|> Enum.flat_map(&extract_references/1)
      #|> Enum.map(&extract_authors/1)
  end

  defp extract_references(row) do
    title = Enum.filter_map(row, &take_title/1, &(elem(&1, 1)))
    pdf = Enum.filter_map(row, &take_pdf/1, &(elem(&1, 1)))
    references = Enum.filter_map(row, &take_text/1, &(elem(&1, 1)))
      |> hd
      |> String.split(~r/^.?Refe?rences$|^.?Bibliography$/m, trim: true)
      #|> Enum.filter_map(fn string_list -> Enum.count(string_list) > 1 end, &(elem(&1, 1)))
      #|> scan_for_references
      #|> Enum.drop_while(fn match_list -> !String.starts_with?(hd(match_list), "[1]") end)
      #|> Enum.map(&format_match/1)
    if (Enum.count(references) == 2) do
      {title, pdf, Enum.at(references, 1)}
    else
      {title, pdf, :none}
    end 
  end

  defp extract_authors(reference) do
    Regex.scan(~r/^(.+?)\. [A-Z][^.]/, reference)
  end


  defp take_text(tuple) do
    take_column(tuple, "PaperText\n")
  end


  defp take_title(tuple) do
    take_column(tuple, "Title")
  end

  defp take_pdf(tuple) do
    take_column(tuple, "PdfName")
  end

  defp take_column(tuple, column) do
    case tuple do
      {^column, _} -> true
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
