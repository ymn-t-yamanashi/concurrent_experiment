defmodule ConcurrentExperiment do
  @moduledoc """
  Documentation for `ConcurrentExperiment`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ConcurrentExperiment.hello()
      :ok

  """
  def hello do
    run_ping = :timer.tc(fn -> run_ping() end)
    run_ping_async = :timer.tc(fn -> run_ping_async() end)

    run_ping |> IO.inspect()
    run_ping_async |> IO.inspect()

    {run_ping_time, _} = run_ping
    {run_ping_async_time, _} = run_ping_async

    run_ping_time / run_ping_async_time |> IO.inspect()

    :ok
  end

  def run_ping_async() do
    task =
    1..10
    |> Enum.map(& ping_async("192.168.0.#{&1}"))

    task
    |> Enum.map(& Task.await(&1))
    |> results_output()
  end

  def run_ping() do
    1..10
    |> Enum.map(& ping("192.168.0.#{&1}"))
    |> results_output()
  end

  def transform_output({results, _}) do
    results
    |> String.split(" ")
    |> Enum.at(1)
  end

  def results_output(results) do
    results
    |> Enum.filter(fn {_ , ok} -> ok == 0 end)
    |> Enum.map(& transform_output(&1))
  end

  def ping_async(ip) do
    Task.async(fn ->
      System.cmd("ping",  ~w"-w 1 #{ip}")
    end)
  end

  def ping(ip) do
      System.cmd("ping",  ~w"-w 1 #{ip}")
  end

end
