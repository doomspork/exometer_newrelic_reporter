defmodule Exometer.NewrelicReporter.Reporter do
  @moduledoc """
  Retrieves stored metrics and sends them to NewRelic every N milliseconds
  """

  use GenServer

  require Logger

  import Exometer.NewrelicReporter.{Aggregator, Formatter, Request}
  import Exometer.NewrelicReporter.Collector, only: [dispense: 0]

  alias __MODULE__, as: Reporter

  @default_interval 60000

  def start_link(opts \\ []),
    do: GenServer.start_link(Reporter, [], name: Reporter)

  @doc """
  Start our reporter and schedule initial report
  """
  def init(opts) do
    Logger.info("Starting NewRelic Reporter")

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
    Logger.info("Reporting to NewRelic")

    dispense
    |> aggregate

    wait_then_report(opts)

    {:noreply, opts}
  end

  defp wait_then_report(opts) do
    Process.send_after(Reporter, :report, opts[:interval])
    opts
  end
end
