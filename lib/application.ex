defmodule Aoc.Application do
  use Application

  def start(_type, _args) do
    Aoc.LocalCache.start_link()
  end
end
