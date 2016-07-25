defmodule Exometer.NewrelicReporter.Formats do
  def format({:counters, name}, data),
    do: counter(name, data)

  @doc """
  Format a counter metric to NewRelic's specification
  """
  def counter(name, data) do
    [{[name: name, scope: ""]},
     [1,    # occurrences
      data, # sum
      data, # sum
      data, # min
      data, # max
      data]]# sum2
  end

  def histogram(name, data), do: nil
end
