defmodule Exometer.NewrelicReporter.Request do
  @behaviour :exometer_report

  require Logger
  require IEx

  alias HTTPoison.Response

  @agent_version "1.5.0.103"
  @base_url "https://~s/agent_listener/invoke_raw_method"
  @collector "collector.newrelic.com"
  @language "python" # We're mimicking newrelic-erlang
  @protocol_v 10

  def post(data, opts) do
    license_key = Keyword.fetch!(opts, :license_key)

    license_key
    |> redirect_host
    |> connect(opts)
    |> push_metrics(data)
  end

  @doc """
  Record metrics on New Relic
  """
  def push_metrics({redirect_host, run_id}, data) do
    now  = :os.system_time(:seconds)
    body = [run_id, now - 60, now, data]
    newrelic_request(redirect_host, body, %{method: :metric_data, run_id: run_id})
  end

  @doc """
  Record an error on New Relic
  """
  def push_errors({redirect_host, run_id}, errors) do
    body = [run_id, errors]
    newrelic_request(redirect_host, body, %{method: :error_data, run_id: run_id})
  end

  defp base_params(license_key) do
    %{
      license_key: license_key,
      marshal_format: :json,
      protocol_version: @protocol_v
    }
  end

  defp connect({redirect_host, license_key}, opts) do
    body =  opts
            |> connect_payload
            |> Poison.encode!

    run_id =
      redirect_host
      |> newrelic_request(license_key, body, %{method: :connect})
      |> extract_return_value
      |> Map.get("agent_run_id")

    {redirect_host, run_id}
  end

  defp connect_payload(opts) do
    app_name      = Keyword.fetch!(opts, :application_name)
    high_security = Keyword.get(opts, :high_security, false)

    [%{
      environment: %{},
      high_security: high_security,
      host: hostname(),
      identifier: app_name,
      language: @language,
      app_name: [app_name],
      pid: pid(),
      settings: %{},
      agent_version: @agent_version
    }]
  end

  defp extract_return_value(%Response{status_code: 200, body: body}) do
    body
    |> Poison.decode!
    |> Map.get("return_value")
  end
  defp extract_return_value(%Response{status_code: _, body: body}) do
    body
    |> Poison.decode!
    |> Map.get("exception")
    |> Map.get("message")
    |> Logger.error
  end

  defp hostname do
    {:ok, hostname} = :inet.gethostname()
    hostname |> to_string
  end

  defp newrelic_params(host, license_key, params) do
    url =
    @base_url
    |> :io_lib.format([host])
    |> to_string

    params =
    license_key
    |> base_params
    |> Map.merge(params)

    {url, params}
  end

  defp newrelic_request(host, license_key, params) do
    {url, params} = newrelic_params(host, license_key, params)
    HTTPoison.get!(url, [], params: params)
  end
  defp newrelic_request(host, license_key, body, params) do
    {url, params} = newrelic_params(host, license_key, params)
    HTTPoison.post!(url, body, [{"Content-Encoding", "identity"}], params: params)
  end

  defp pid, do: :os.getpid() |> List.to_integer

  defp redirect_host(license_key) do
    redirect_host =
    @collector
    |> newrelic_request(license_key, %{method: :get_redirect_host})
    |> extract_return_value

    {redirect_host, license_key}
  end
end
