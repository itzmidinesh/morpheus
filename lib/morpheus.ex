defmodule Morpheus do
  @moduledoc """
  Morpheus is an Elixir library for converting between camelCase and snake_case in Phoenix projects.
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

  def snake_to_camel(string) when is_binary(string) do
    string
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
    |> downcase_first()
  end

  def snake_to_camel(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> snake_to_camel()
    |> String.to_atom()
  end

  def snake_to_camel(input), do: input

  defp downcase_first(<<first::utf8, rest::binary>>), do: String.downcase(<<first>>) <> rest

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

  defp convert_key(key, conversion_function) when is_atom(key) or is_binary(key) do
    conversion_function.(key)
  end

  defp convert_key(key, _conversion_function), do: key
end
