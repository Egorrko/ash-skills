defmodule Checks.FileLength do
  @moduledoc false
  # An agent edits a long file by fragments and misses what it already contains, so
  # the same thing gets written twice. The limit keeps every file readable whole.
  use Credo.Check,
    base_priority: :high,
    category: :design,
    param_defaults: [max_lines: 600],
    explanations: [
      check: """
      A file longer than :max_lines is split by responsibility: an Ash resource's
      changes, validations and calculations go to their own modules, a LiveView's
      event groups to components or helper modules.
      """,
      params: [max_lines: "The longest file allowed, in lines."]
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    max = Params.get(params, :max_lines, __MODULE__)
    lines = source_file |> SourceFile.lines() |> length()

    if lines > max do
      ctx = Context.build(source_file, params, __MODULE__)
      [format_issue(ctx, message: "#{lines} lines, the limit is #{max}: split it by responsibility.", line_no: 1)]
    else
      []
    end
  end
end
