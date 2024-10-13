defmodule Morpheus.Encoder do
  @moduledoc """
  Configuration module for Morpheus to handle camelCase conversion.

  This module provides functions to encode Elixir data structures into JSON
  while converting map keys from snake_case to camelCase.

  It relies on the `Morpheus` module for key conversion and `Jason` for JSON encoding.
  """

  @doc """
  Encodes the given data structure to JSON with snake_case keys converted to camelCase.

  ## Parameters

    * `data` - The Elixir data structure to be encoded.
    * `opts` - Optional keyword list of options to be passed to `Jason.encode!/2`.

  ## Examples

      iex> data = %{user_name: "John Doe", age: 30}
      iex> Morpheus.Encoder.encode(data)
      "{\"age\":30,\"userName\":\"John Doe\"}"

  """

  def encode(data, opts \\ []) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode!(opts)
  end

  @doc """
  Encodes the given data structure to JSON with snake_case keys converted to camelCase,
  returning an iodata.

  ## Parameters

    * `data` - The Elixir data structure to be encoded.

  ## Examples

      iex> data = %{user_name: "John Doe", age: 30}
      iex> Morpheus.Encoder.encode_to_iodata!(data)
      [
  "{\"", [[] | "age"], "\":", "30", ",\"", [[] | "userName"], "\":", [34, [[] | "John Doe"], 34], 125]

  """

  def encode_to_iodata!(data) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode_to_iodata!()
  end
end
