defmodule Morpheus do
  @moduledoc """
  Morpheus is an Elixir library for converting between camelCase and snake_case in Phoenix projects.

  This module provides functions to convert strings, atoms, maps, and lists between camelCase and snake_case.
  It's particularly useful for handling JSON payloads in Phoenix applications where JavaScript conventions (camelCase)
  need to be converted to Elixir conventions (snake_case) and vice versa.

  ## Main Functions

  - `camel_to_snake/1`: Converts camelCase to snake_case
  - `snake_to_camel/1`: Converts snake_case to camelCase
  - `convert_map_keys/2`: Recursively converts keys in maps and lists using a provided conversion function
  """

  @doc """
  Converts a camelCase string or atom to snake_case.

  Returns the input unchanged if it's neither a string nor an atom.

  ## Examples

      iex> Morpheus.camel_to_snake("userFirstName")
      "user_first_name"

      iex> Morpheus.camel_to_snake(:userFirstName)
      :user_first_name

      iex> Morpheus.camel_to_snake("API")
      "api"

      iex> Morpheus.camel_to_snake("APIResponse")
      "api_response"

      iex> Morpheus.camel_to_snake("HTMLParser")
      "html_parser"

      iex> Morpheus.camel_to_snake("iOS")
      "i_os"

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

  Returns the input unchanged if it's neither a string nor an atom.

  ## Examples

      iex> Morpheus.snake_to_camel("user_first_name")
      "userFirstName"

      iex> Morpheus.snake_to_camel(:user_first_name)
      :userFirstName

      iex> Morpheus.snake_to_camel("API_key")
      "apiKey"

      iex> Morpheus.snake_to_camel("API")
      "api"

      iex> Morpheus.snake_to_camel(123)
      123

      iex> Morpheus.snake_to_camel([1, 2, 3])
      [1, 2, 3]
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

  This function can be used with either `camel_to_snake/1` or `snake_to_camel/1` to convert
  all keys in a nested data structure.

  ## Parameters

    * `data` - The map, list, or other value to convert
    * `conversion_function` - The function to apply to each key (e.g., `&Morpheus.camel_to_snake/1`)

  ## Examples

      iex> data = %{"userInfo" => %{"firstName" => "John", "lastName" => "Doe"}}
      iex> Morpheus.convert_map_keys(data, &Morpheus.camel_to_snake/1)
      %{"user_info" => %{"first_name" => "John", "last_name" => "Doe"}}

      iex> data = [%{user_id: 1, user_name: "John"}, %{user_id: 2, user_name: "Jane"}]
      iex> Morpheus.convert_map_keys(data, &Morpheus.snake_to_camel/1)
      [%{userId: 1, userName: "John"}, %{userId: 2, userName: "Jane"}]

      iex> Morpheus.convert_map_keys("not_a_map", &Morpheus.snake_to_camel/1)
      "not_a_map"
  """
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
