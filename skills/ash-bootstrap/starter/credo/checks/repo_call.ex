defmodule Checks.RepoCall do
  @moduledoc false
  # A direct Repo call bypasses the Ash actions, policies and validations that the
  # product's behavior lives in. .credo.exs lists the files allowed to make one.
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Persisted state goes through Ash actions, so policies, validations and changes run.
      A direct `Repo` call skips all of them. Write the behavior as an Ash action, or,
      for a measured hot path, add the file to this check's `excluded` list in
      `.credo.exs` with the reason beside it.
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__)
    result = Credo.Code.prewalk(source_file, &walk/2, ctx)
    result.issues
  end

  defp walk({{:., _, [{:__aliases__, _, parts}, fun]}, meta, _args} = ast, ctx)
       when is_list(parts) and is_atom(fun) do
    if List.last(parts) == :Repo do
      {ast, put_issue(ctx, issue_for(ctx, meta, Enum.join(parts, ".") <> "." <> Atom.to_string(fun)))}
    else
      {ast, ctx}
    end
  end

  defp walk(ast, ctx), do: {ast, ctx}

  defp issue_for(ctx, meta, call) do
    format_issue(ctx,
      message: "#{call} bypasses Ash: write it as an Ash action, or list this file in .credo.exs with the reason.",
      trigger: call,
      line_no: meta[:line]
    )
  end
end
