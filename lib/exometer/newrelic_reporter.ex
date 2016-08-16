defmodule Exometer.NewrelicReporter do
  @behaviour :exometer_report

  alias HTTPoison.Response
  alias Exometer.NewrelicReporter.Collector

  @doc """
  Entrypoint to our reporter, invoked by Exometer with configuration options.
  """
  def exometer_init(opts), do: {:ok, opts}

  @doc """
  Invoked by Exometer when there is new data to report.
  """
  def exometer_report(metric, _data_point, _extra, values, opts) do
    Collector.collect(metric, values)

    {:ok, opts}
  end

  def exometer_call(_, _, opts),            do: {:ok, opts}
  def exometer_cast(_, opts),               do: {:ok, opts}
  def exometer_info(_, opts),               do: {:ok, opts}
  def exometer_newentry(_, opts),           do: {:ok, opts}
  def exometer_setopts(_, _, _, opts),      do: {:ok, opts}
  def exometer_subscribe(_, _, _, _, opts), do: {:ok, opts}
  def exometer_terminate(_, _),             do: nil
  def exometer_unsubscribe(_, _, _, opts),  do: {:ok, opts}
end
