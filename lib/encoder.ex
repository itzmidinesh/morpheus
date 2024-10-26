defmodule Morpheus.Encoder do
  @moduledoc """
  Transforms JSON responses in Phoenix applications from Elixir's snake_case to JavaScript's camelCase format.

  This module allows you to work with idiomatic Elixir snake_case in your codebase
  while serving camelCase JSON to your API clients.

  ## Setup

  In your config/config.exs, add after Jason config:

      config :phoenix, :format_encoders, json: Morpheus.Encoder

  That's it! Your JSON responses will now automatically convert keys to camelCase.

  ## Usage

  ### In Phoenix Controllers

      # No Changes required
      def show(conn, _params) do
        user = %{
          user_id: 1,
          first_name: "John",
          last_name: "Doe"
        }
        json(conn, user)
      end

  ### In JSON Views

      # No Changes required
      defmodule MyAppWeb.UserJSON do
        def show(%{user: user}) do
          %{data: data(user)}
        end

        defp data(%User{} = user) do
          %{
            id: user.id,
            first_name: user.first_name,
            last_name: user.last_name
          }
        end
      end

  ### Direct Usage

      # For manual encoding when needed
      Morpheus.Encoder.encode(%{user_name: "John"})

  ## How it Works

  When Phoenix renders a JSON response, it uses this encoder which:
  1. Recursively traverses all maps and lists in the data structure
  2. Converts all keys from snake_case to camelCase
  3. Passes the transformed data to Jason for final JSON encoding

  ## Configuration Options

  You can configure encoding options in your config:

      config :morpheus, encode_options: [pretty: true]  # Passes these options to Jason.encode!/2
  """

  @doc """
  Encodes the given data structure to JSON with snake_case keys converted to camelCase.

  This function is called automatically by Phoenix when rendering JSON responses.

  ## Parameters

    * `data` - The Elixir data structure to be encoded
    * `opts` - Optional keyword list of options to be passed to `Jason.encode!/2`

  ## Examples

      iex> data = %{user_name: "John Doe", age: 30}
      iex> Morpheus.Encoder.encode(data)
      "{\"age\":30,\"userName\":\"John Doe\"}"

      # With pretty printing
      iex> data = %{user_name: "John Doe"}
      iex> Morpheus.Encoder.encode(data, pretty: true)
      \"\"\"
      {
        "userName": "John Doe"
      }
      \"\"\"

      # Nested structures
      iex> data = %{user_info: %{first_name: "John"}}
      iex> Morpheus.Encoder.encode(data)
      "{\"userInfo\":{\"firstName\":\"John\"}}"
  """
  def encode(data, opts \\ []) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode!(opts)
  end

  @doc """
  Encodes the given data structure to JSON with snake_case keys converted to camelCase,
  returning an iodata.

  This is useful when you want to avoid creating an intermediate binary string,
  especially when dealing with large data structures.

  ## Parameters

    * `data` - The Elixir data structure to be encoded

  ## Examples

      # Basic usage
      iex> data = %{user_name: "John"}
      iex> iodata = Morpheus.Encoder.encode_to_iodata!(data)
      iex> IO.iodata_to_binary(iodata)
      "{\"userName\":\"John\"}"

      # With nested structures
      iex> data = %{user_info: %{first_name: "John"}}
      iex> iodata = Morpheus.Encoder.encode_to_iodata!(data)
      iex> IO.iodata_to_binary(iodata)
      "{\"userInfo\":{\"firstName\":\"John\"}}"
  """
  def encode_to_iodata!(data) do
    data
    |> Morpheus.convert_map_keys(&Morpheus.snake_to_camel/1)
    |> Jason.encode_to_iodata!()
  end
end
