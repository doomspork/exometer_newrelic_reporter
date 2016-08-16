defmodule Exometer.NewrelicReporter.Mixfile do
  use Mix.Project

  def project do
    [app: :exometer_newrelic_reporter,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:httpoison, :logger],
     mod: {Exometer.NewrelicReporter, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.9.0"},
     {:poison, "~> 2.0"}]
  end
end
