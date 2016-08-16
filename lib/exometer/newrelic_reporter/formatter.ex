defmodule Exometer.NewrelicReporter.Formatter do
  def format({:counters, name}, data),
    do: [counter(name, data)]

  @doc """
  Format a counter metric to NewRelic's specification
  """
  def counter(name, data) do
    [stat_key(name),
     [1,    # occurrences (int)
      data, # sum (float)
      data, # sum (float)
      data, # min (float)
      data, # max (float)
      data]]# sum2 (float)
  end

  @doc """
  Format a histogram for NewRelic
  """
  def histogram(name, data), do: nil

  defp stat_key(name, scope \\ ""), do: %{name: name, scope: scope}
end
