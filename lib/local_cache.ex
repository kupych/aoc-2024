defmodule Aoc.LocalCache do
  use Nebulex.Cache,
    otp_app: :aoc,
    adapter: Nebulex.Adapters.Local
end
