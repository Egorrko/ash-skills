defmodule Checks.DomainBoundary do
  @moduledoc false
  # An Ash domain is a boundary: `use Boundary` lists the domains it may call, and
  # `mix compile` fails on any other reference and on a cycle. A domain without the
  # declaration is open to every module, so the rule only holds once each one has it.
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Every module with `use Ash.Domain` also has
      `use Boundary, deps: [<the domains it calls>], exports: :all`.
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__)
    result = Credo.Code.prewalk(source_file, &walk/2, ctx)
    result.issues
  end

  defp walk({:defmodule, meta, [_name, [do: body]]} = ast, ctx) do
    uses = body |> statements() |> Enum.flat_map(&used/1)

    if :"Ash.Domain" in uses and :Boundary not in uses do
      {ast,
       put_issue(
         ctx,
         format_issue(ctx,
           message: "An Ash domain declares its boundary: use Boundary, deps: [...], exports: :all.",
           line_no: meta[:line]
         )
       )}
    else
      {ast, ctx}
    end
  end

  defp walk(ast, ctx), do: {ast, ctx}

  defp statements({:__block__, _, list}), do: list
  defp statements(single), do: [single]

  defp used({:use, _, [{:__aliases__, _, parts} | _]}), do: [parts |> Enum.join(".") |> String.to_atom()]
  defp used(_), do: []
end
