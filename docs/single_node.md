# Single Node Transformations

## Empty enum checks

This addresses [`Credo.Check.Warning.ExpensiveEmptyEnumCheck`](https://hexdocs.pm/credo/Credo.Check.Warning.ExpensiveEmptyEnumCheck.html).  This is not configurable.

Rewrites look like this:

```elixir
# Given:
if enum |> MyModule.transform() |> length() == 0, do: "empty"
# Styled:
if enum |> MyModule.transform() |> Enum.empty?(), do: "empty"

# Given:
if Enum.count(enum) > 0, do: "not empty"
# Styled:
if not Enum.empty?(enum), do: "not empty"
```

Note that while Quokka will rewrite the calls to `length/1` or `Enum.count/1` even in pipes when the result is being checked for equality against zero, it will not rewrite pipes if they're being checked for being greater than zero. (Quokka avoids either wrapping the whole pipe chain in a `not` or piping into `Kernel.not/1`.)

```elixir
# Given:
if foo |> MyModule.transform() |> Enum.count(enum) > 0, do: "not empty"
# Styled (unchanged):
if foo |> MyModule.transform() |> Enum.count(enum) > 0, do: "not empty"
```
