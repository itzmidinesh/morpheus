defmodule Morpheus do
  @moduledoc """
  Morpheus is an Elixir library for converting between camelCase and snake_case in Phoenix applications.

  This module provides key conversion utilities for JSON payloads, allowing your Phoenix application
  to seamlessly work with camelCase (JavaScript) and snake_case (Elixir) conventions.

  ## Installation

  Add to your mix.exs:

      def deps do
        [
          {:morpheus, "~> 0.1.2"}
        ]
      end

  ## Key Features

    * Converts between camelCase and snake_case for strings and atoms
    * Handles nested data structures (maps and lists)
    * Preserves non-convertible values
    * Properly handles acronyms (API, HTML, iOS)

  ## Quick Start

      # Basic conversion
      "user_name" |> Morpheus.snake_to_camel()     # => "userName"
      "userName" |> Morpheus.camel_to_snake()      # => "user_name"

      # Convert map keys
      data = %{user_profile: %{first_name: "John"}}
      Morpheus.convert_map_keys(data, &Morpheus.snake_to_camel/1)
      # => %{userProfile: %{firstName: "John"}}

  ## Usage with Phoenix

  For automatic JSON conversion, see `Morpheus.Encoder`.
  """

  @doc """
  Converts a camelCase string or atom to snake_case.

  ## String Conversion

      # Basic conversion
      iex> Morpheus.camel_to_snake("userName")
      "user_name"

      # Multiple words
      iex> Morpheus.camel_to_snake("userFirstName")
      "user_first_name"

  ## Acronym Handling


      # Consecutive capitals
      iex> Morpheus.camel_to_snake("API")
      "api"

      # Mixed case acronyms
      iex> Morpheus.camel_to_snake("APIResponse")
      "api_response"

  ## Atom Conversion

      iex> Morpheus.camel_to_snake(:userFirstName)
      :user_first_name

  ## Other Types

  Returns the input unchanged if it's neither a string nor an atom:

      iex> Morpheus.camel_to_snake(123)
      123

      iex> Morpheus.camel_to_snake([1, 2, 3])
      [1, 2, 3]
  """
  def camel_to_snake(string) when is_binary(string) do
    string
    |> String.replace(~r/(?<=[a-z])(?=[A-Z])|\B(?=[A-Z][a-z])/, "_")
    |> String.downcase()
  end

  def camel_to_snake(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> camel_to_snake()
    |> String.to_atom()
  end

  def camel_to_snake(input), do: input

  @doc """
  Converts a snake_case string or atom to camelCase.

  ## String Conversion

      # Basic conversion
      iex> Morpheus.snake_to_camel("user_name")
      "userName"

      # Multiple words
      iex> Morpheus.snake_to_camel("user_first_name")
      "userFirstName"

  ## Special Cases

      # Double underscores
      iex> Morpheus.snake_to_camel("user__name")
      "userName"

      # Acronyms
      iex> Morpheus.snake_to_camel("api_key")
      "apiKey"

      # All caps
      iex> Morpheus.snake_to_camel("API")
      "api"

  ## Atom Conversion

      iex> Morpheus.snake_to_camel(:user_first_name)
      :userFirstName

  ## Other Types

  Returns the input unchanged if it's neither a string nor an atom:

      iex> Morpheus.snake_to_camel(123)
      123
  """
  def snake_to_camel(string) when is_binary(string) do
    cond do
      String.contains?(string, "_") ->
        string
        |> String.split("_")
        |> Enum.map_join(&String.capitalize/1)
        |> downcase_first()

      String.upcase(string) == string ->
        String.downcase(string)

      true ->
        string
    end
  end

  def snake_to_camel(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> snake_to_camel()
    |> String.to_atom()
  end

  def snake_to_camel(input), do: input

  @doc false
  # Private helper function to downcase the first character of a string
  defp downcase_first(<<first::utf8, rest::binary>>), do: String.downcase(<<first>>) <> rest

  @doc """
  Recursively converts keys in maps and lists using the provided conversion function.

  ## Use Cases

    * Converting API request/response payloads
    * Transforming database results
    * Normalizing data structures

  ## Examples

  ### Nested Maps

      iex> data = %{
      ...>   "userInfo" => %{
      ...>     "firstName" => "John",
      ...>     "lastName" => "Doe"
      ...>   }
      ...> }
      iex> Morpheus.convert_map_keys(data, &Morpheus.camel_to_snake/1)
      %{
        "user_info" => %{
          "first_name" => "John",
          "last_name" => "Doe"
        }
      }

  ### Lists of Maps

      iex> users = [
      ...>   %{user_id: 1, user_name: "John"},
      ...>   %{user_id: 2, user_name: "Jane"}
      ...> ]
      iex> Morpheus.convert_map_keys(users, &Morpheus.snake_to_camel/1)
      [
        %{userId: 1, userName: "John"},
        %{userId: 2, userName: "Jane"}
      ]

  ### Mixed Key Types

      iex> data = %{"user_name" => "John", last_name: "Doe"}
      iex> Morpheus.convert_map_keys(data, &Morpheus.snake_to_camel/1)
      %{"userName" => "John", lastName: "Doe"}

  ### Structs

      iex> data = %{date: ~D[2025-03-23]}
      iex> Morpheus.convert_map_keys(data, &Morpheus.snake_to_camel/1)
      %{date: ~D[2025-03-23]}

      iex> data = %{file: %Plug.Upload{path: "/tmp/file.txt", content_type: "text/plain", filename: "file.txt"}}
      iex> Morpheus.convert_map_keys(data, &Morpheus.snake_to_camel/1)
      %{file: %Plug.Upload{path: "/tmp/file.txt", content_type: "text/plain", filename: "file.txt"}}

  ### Non-convertible Values

      iex> Morpheus.convert_map_keys("not_a_map", &Morpheus.snake_to_camel/1)
      "not_a_map"
  """
  def convert_map_keys(struct, _conversion_function) when is_struct(struct), do: struct

  def convert_map_keys(map, conversion_function) when is_map(map) do
    map
    |> Enum.map(fn {key, value} ->
      {convert_key(key, conversion_function), convert_map_keys(value, conversion_function)}
    end)
    |> Enum.into(%{})
  end

  def convert_map_keys(list, conversion_function) when is_list(list) do
    Enum.map(list, &convert_map_keys(&1, conversion_function))
  end

  def convert_map_keys(value, _conversion_function), do: value

  @doc false
  # Private helper function to convert a key using the provided conversion function
  defp convert_key(key, conversion_function) when is_atom(key) or is_binary(key) do
    conversion_function.(key)
  end

  defp convert_key(key, _conversion_function), do: key
end
