# Credo: the default checks plus the architecture checks of the quality harness
# (STACK_POLICY.md). Custom checks live in credo/checks/, outside lib/, so the
# release never compiles them.
%{
  configs: [
    %{
      name: "default",
      files: %{included: ["lib/", "test/"], excluded: [~r"/_build/", ~r"/deps/"]},
      requires: ["credo/checks/*.ex"],
      strict: true,
      checks: %{
        extra: [
          {Checks.RepoCall,
           [
             files: %{
               # Each entry says why this file may call Repo directly.
               excluded: [
                 # the Repo itself and the release tasks (migrations on start)
                 "lib/<app>/repo.ex",
                 "lib/<app>/release.ex"
               ],
               # tests may set up state with Repo; the rule guards the product code
               included: ["lib/"]
             }
           ]},
          {Checks.DomainBoundary, []},
          {Checks.FileLength, [max_lines: 600]}
        ]
      }
    }
  ]
}
