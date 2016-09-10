defmodule Thumbnex.Mixfile do
  use Mix.Project

  def project do
    [app: :thumbnex,
     version: "0.2.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mogrify, "~> 0.4.0"},
     {:ffmpex, "~> 0.3.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    "Create thumbnails from images and video screenshots."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Andrew Shu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/talklittle/thumbnex"}
    ]
  end
end
