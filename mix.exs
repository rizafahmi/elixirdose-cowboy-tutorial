defmodule DoseFramework.Mixfile do
  use Mix.Project

  def project do
    [app: :dose_framework,
     version: "0.0.1",
     elixir: "~> 0.13.1",
     deps: deps]
  end

  def application do
    [ applications: [:cowboy, :ex_doc],
      mod: {DoseFramework, []} ]
  end

  defp deps do
    [
      {:cowboy, github: "extend/cowboy"},
      {:ex_doc, github: "elixir-lang/ex_doc"}

      ]
  end
end
