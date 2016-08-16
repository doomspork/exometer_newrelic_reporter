defmodule Exometer.NewrelicReporter.Reporter do
  @moduledoc """
  Retrieves stored metrics and sends them to NewRelic every N milliseconds
  """

  use GenServer

  import Exometer.NewrelicReporter.{Aggregator, Formatter, Reporter}
  import Exometer.NewrelicReporter.Collector, only: [:dispense]

  @default_interval 60000

  @doc """
  Start our reporter and schedule initial report
  """
  def init(opts) do
    opts =
      opts
      |> Keyword.put_new(:interval, @default_interval)
      |> wait_then_report

    {:ok, opts}
  end

  @doc """
  Collect, aggregate, format, and report our metrics to NewRelic
  """
  def handle_info(:report, opts) do
    dispense
    |> aggregate
    |> format
    |> report(opts)

    wait_then_report(opts)

    {:ok, opts}
  end

  defp wait_then_report(opts) do
    send_after(self(), :report, opts[:interval])
    opts
  end
end
