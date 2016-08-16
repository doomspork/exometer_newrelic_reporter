defmodule Exometer.NewrelicReporter.Collector do
  @moduledoc """
  A collector for our NewRelic metrics.  Allows for storage, aggregation, and retrieval
  of our metric data
  """

  use GenServer

  require Logger

  alias __MODULE__, as: Collector

  @empty_storage %{}

  def start_link(opts \\ []),
    do: GenServer.start_link(Collector, [], name: Collector)

  @doc """
  Initialize our Collector with empty storage
  """
  def init(_opts) do
    Logger.info("Starting NewRelic Collector")

    {:ok, storage: @empty_storage}
  end

  @doc """
  Record the metric data at the given key on the GenServer
  """
  def collect(stat_key, data), do: GenServer.cast(Collector, {stat_key, data})

  @doc """
  Asynchronsously store our metric data by the type and name derived from the stat key
  """
  def handle_cast({stat_key, data}, opts) do
    storage =
      stat_key
      |> type_and_name
      |> store(data, opts)

    opts = Keyword.update!(opts, :storage, storage)

    {:noreply, opts}
  end

  @doc """
  Dispense all of our stored metrics
  """
  def dispense, do: GenServer.call(Collector, :dispense)

  @doc """
  Retrieve the current stored values and reset storage
  """
  def handle_call(:dispense, _from, opts) do
    {data, opts} = Keyword.get_and_update(opts, :storage, &({&1, @empty_storage}))

    {:reply, data, opts}
  end

  defp store(key, data, opts) do
    now = :os.system_time(:seconds)

    :storage
    |> Keyword.fetch!
    |> Map.update(key, [], &(&1 ++ [{now, data}]))
  end

  defp type_and_name(metric) do
    [_app, _env, type] = Enum.slice(metric, 0..2)
    name =
      metric
      |> Enum.slice(3..-1)
      |> Enum.join("/")

    {type, name}
  end
end
