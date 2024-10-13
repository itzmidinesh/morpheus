defmodule Morpheus.Encoder do
  @moduledoc """
  Configuration module for Morpheus to handle camelCase conversion.
  """

  def encode(data, opts \\ []) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode!(opts)
  end

  def encode_to_iodata!(data) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode_to_iodata!()
  end
end
