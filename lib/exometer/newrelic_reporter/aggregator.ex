defmodule Exometer.NewrelicReporter.Aggregator do
  @moduledoc """
  Aggregate our collection of data points
  """

  require Logger

  alias __MODULE__, as: Aggregator

  @histogram_fields = ~w(observations min max sum sum2)a

  def aggregate(data) when is_map(data) do
    data
    |> Map.to_list
    |> Enum.map(&Aggregator.aggregate/1)
  end

  def aggregate({{:counters, name} = key, metrics}) do
    agg = aggregate_counter(metrics)
    {key, agg}
  end

  def aggregate({{:histogram, name} = key, metrics}) do
    agg = aggregate_histogram(metrics)
    {key, agg}
  end

  def aggregate({{type, _}, _}), do: Logger.info("Unhandled type: #{type}")

  defp aggregate_histogram(name, metrics) do
    n = Enum.count(metrics)
    %{observations: observations, min: min, max: max, sum: sum, sum2: sum2} = average_histogram(metrics)
    key = stat_key(name)

    [key, [observations, sum / n, sum / n, min / n, max / n, sum2 / n]]
  end

  defp aggregate_counter(name, metrics) do
    n   = Enum.count(metrics)
    min = Enum.min(metrics)
    max = Enum.max(metrics)
    sum = Enum.sum(metrics)
    key = stat_key(name)

    [key, [n, sum, sum, min, max, sum]]
  end

  defp average_histogram([]), do: %{}
  defp average_histogram(metrics), do: Enum.reduce(metrics, %{}, &Aggregator.average_histogram/2)
  defp average_histogram([], acc), do: acc
  defp average_histogram(value, acc) do
    Enum.reduce(@histogram_fields, acc, fn (field, memo) ->
      val = value[field]
      Map.update(memo, field, val, &(&1 + val))
    end)
  end
  defp average_histogram([], acc), do: acc

  defp stat_key(name, scope \\ ""), do: %{name: name, scope: scope}
end
