# Copyright 2024 Adobe. All rights reserved.
# This file is licensed to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
# OF ANY KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.

defmodule Quokka.Style.CommentDirectivesTest do
  @moduledoc false
  use Quokka.StyleCase, async: true

  describe "sort" do
    test "sorts all maps if the config is set" do
      Mimic.stub(Quokka.Config, :sort_all_maps?, fn -> true end)
      assert_style(
        """
        %{c: 2, b: 3, a: 4, d: 1}
        """,
        """
        %{a: 4, b: 3, c: 2, d: 1}
        """
      )
    end

    test "skips sorting when config is set and there is a skip-sort directive" do
      Mimic.stub(Quokka.Config, :sort_all_maps?, fn -> true end)
      assert_style(
        """
        # quokka:skip-sort
        %{c: 2, b: 3, a: 4, d: 1}
        """
      )
    end


    test "we dont just sort by accident" do
      assert_style "[:c, :b, :a]"
    end

    test "sorts lists of atoms" do
      assert_style(
        """
        # quokka:sort
        [
          :c,
          :b,
          :c,
          :a
        ]
        """,
        """
        # quokka:sort
        [
          :a,
          :b,
          :c,
          :c
        ]
        """
      )
    end

    test "sort keywordy things" do
      assert_style(
        """
        # quokka:sort
        [
          c: 2,
          b: 3,
          a: 4,
          d: 1
        ]
        """,
        """
        # quokka:sort
        [
          a: 4,
          b: 3,
          c: 2,
          d: 1
        ]
        """
      )

      assert_style(
        """
        # quokka:sort
        %{
          c: 2,
          b: 3,
          a: 4,
          d: 1
        }
        """,
        """
        # quokka:sort
        %{
          a: 4,
          b: 3,
          c: 2,
          d: 1
        }
        """
      )

      assert_style(
        """
        # quokka:sort
        %Struct{
          c: 2,
          b: 3,
          a: 4,
          d: 1
        }
        """,
        """
        # quokka:sort
        %Struct{
          a: 4,
          b: 3,
          c: 2,
          d: 1
        }
        """
      )

      assert_style(
        """
        # quokka:sort
        defstruct c: 2, b: 3, a: 4, d: 1
        """,
        """
        # quokka:sort
        defstruct a: 4, b: 3, c: 2, d: 1
        """
      )

      assert_style(
        """
        # quokka:sort
        defstruct [
          :repo,
          :query,
          :order,
          :chunk_size,
          :timeout,
          :cursor
        ]
        """,
        """
        # quokka:sort
        defstruct [
          :chunk_size,
          :cursor,
          :order,
          :query,
          :repo,
          :timeout
        ]
        """
      )
    end

    test "inside keywords" do
      assert_style(
        """
        %{
          key:
          # quokka:sort
          [
            3,
            2,
            1
          ]
        }
        """,
        """
        %{
          # quokka:sort
          key: [
            1,
            2,
            3
          ]
        }
        """
      )

      assert_style(
        """
        %{
          # quokka:sort
          key: [
            3,
            2,
            1
          ]
        }
        """,
        """
        %{
          # quokka:sort
          key: [
            1,
            2,
            3
          ]
        }
        """
      )
    end

    test "sorts sigils" do
      assert_style("# quokka:sort\n~w|c a b|", "# quokka:sort\n~w|a b c|")

      assert_style(
        """
        # quokka:sort
        ~w(
          a
          long
          list
          of
          static
          values
        )
        """,
        """
        # quokka:sort
        ~w(
          a
          list
          long
          of
          static
          values
        )
        """
      )
    end

    test "assignments" do
      assert_style(
        """
        # quokka:sort
        my_var =
          ~w(
            a
            long
            list
            of
            static
            values
          )
        """,
        """
        # quokka:sort
        my_var =
          ~w(
            a
            list
            long
            of
            static
            values
          )
        """
      )

      assert_style(
        """
        defmodule M do
          @moduledoc false
          # quokka:sort
          @attr ~w(
              a
              long
              list
              of
              static
              values
            )
        end
        """,
        """
        defmodule M do
          @moduledoc false
          # quokka:sort
          @attr ~w(
              a
              list
              long
              of
              static
              values
            )
        end
        """
      )
    end

    test "doesnt affect downstream nodes" do
      assert_style(
        """
        # quokka:sort
        [:c, :a, :b]

        @country_codes ~w(
          po_PO
          en_US
          fr_CA
          ja_JP
        )
        """,
        """
        # quokka:sort
        [:a, :b, :c]

        @country_codes ~w(
          po_PO
          en_US
          fr_CA
          ja_JP
        )
        """
      )
    end

    test "list of tuples" do
      # 2ples are represented as block literals while >2ples are created via `:{}`
      # decided the easiest way to handle this is to just use string representation for meow
      assert_style(
        """
        # quokka:sort
        [
          {:styler, github: "adobe/elixir-styler"},
          {:ash, "~> 3.0"},
          {:fluxon, "~> 1.0.0", repo: :fluxon},
          {:phoenix_live_reload, "~> 1.2", only: :dev},
          {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}
        ]
        """,
        """
        # quokka:sort
        [
          {:ash, "~> 3.0"},
          {:fluxon, "~> 1.0.0", repo: :fluxon},
          {:phoenix_live_reload, "~> 1.2", only: :dev},
          {:styler, github: "adobe/elixir-styler"},
          {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}
        ]
        """
      )
    end

    test "nodes within a do end block" do
      assert_style(
        """
        # quokka:sort
        my_macro "some arg" do
          another_macro :q
          # w
          another_macro :w
          another_macro :e
          # r comment 1
          # r comment 2
          another_macro :r
          another_macro :t
          another_macro :y
        end
        """,
        """
        # quokka:sort
        my_macro "some arg" do
          another_macro(:e)
          another_macro(:q)
          # r comment 1
          # r comment 2
          another_macro(:r)
          another_macro(:t)
          # w
          another_macro(:w)
          another_macro(:y)
        end
        """
      )
    end

    test "treats comments nicely" do
      assert_style(
        """
        # pre-amble comment
        # quokka:sort
        [
          {:phoenix, "~> 1.7"},
          # hackney comment
          {:hackney, "1.18.1", override: true},
          {:styler, "~> 1.2", only: [:dev, :test], runtime: false},
          {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
          {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},
          # ecto
          {:ecto, "~> 3.12"},
          {:ecto_sql, "~> 3.12"},
          # genstage comment 1
          # genstage comment 2
          {:gen_stage, "~> 1.0", override: true},
          # telemetry
          {:telemetry, "~> 1.0", override: true},
          # dangling comment
        ]

        # some other comment
        """,
        """
        # pre-amble comment
        # quokka:sort
        [
          {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
          # ecto
          {:ecto, "~> 3.12"},
          {:ecto_sql, "~> 3.12"},
          {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},
          # genstage comment 1
          # genstage comment 2
          {:gen_stage, "~> 1.0", override: true},
          # hackney comment
          {:hackney, "1.18.1", override: true},
          {:phoenix, "~> 1.7"},
          {:styler, "~> 1.2", only: [:dev, :test], runtime: false},
          # telemetry
          {:telemetry, "~> 1.0", override: true}
          # dangling comment
        ]

        # some other comment
        """
      )
    end
  end
end
