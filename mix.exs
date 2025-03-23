defmodule Morpheus.MixProject do
  use Mix.Project

  def project do
    [
      app: :morpheus,
      version: "0.1.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:plug, "~> 1.16", only: [:dev, :test]},
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    "Morpheus is an Elixir library for converting between camelCase and snake_case in Phoenix projects."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/itzmidinesh/morpheus"},
      maintainers: ["Dinesh Anbazhagan"],
      authors: ["Dinesh Anbazhagan"]
    ]
  end
end
