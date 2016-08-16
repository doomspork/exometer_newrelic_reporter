# Exometer NewRelic Reporter

A [exometer](https://github.com/Feuerlabs/exometer) reporter for [New Relic](https://newrelic.com/).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `exometer_newrelic_reporter` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exometer_newrelic_reporter, github: "doomspork/exometer_newrelic_reporter", "> 0.0.0"}]
    end
    ```

  2. Ensure `exometer_newrelic_reporter` is started before your application:

    ```elixir
    def application do
      [applications: [:exometer_newrelic_reporter]]
    end
    ```
