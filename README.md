# Exometer NewRelic Reporter

A [exometer](https://github.com/Feuerlabs/exometer)/[elixometer](https://github.com/pinterest/elixometer) reporter for [New Relic](https://newrelic.com/).

_Currently under active development_

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

## Configuration

The following assumes you're using Elixometer though configuration should be similar for Exometer:

```markdown
config :exometer_core, report: [
  reporters: ["Elixir.Exometer.NewrelicReporter":
    [
      application_name: "MyApp",
      license_key: System.get_env("NEWRELIC_LICENSE_KEY")
    ]
  ]
]

config :elixometer, reporter: :"Elixir.Exometer.NewrelicReporter",
  update_frequency: 5_000
```

Note the `"Elixir."` prefix when setting our module, this is required by exometer and Erlang in order to lookup the module.
