defmodule Morpheus do
  @moduledoc """
  Morpheus is an Elixir library for converting between camelCase and snake_case in Phoenix projects.
  """

  def camel_to_snake(string) when is_binary(string) do
    string
    |> String.replace(~r/([A-Z])/, "_\\1")
    |> String.downcase()
    |> String.trim_leading("_")
  end

  def snake_to_camel(string) when is_binary(string) do
    string
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
    |> downcase_first()
  end

  defp downcase_first(<<first::utf8, rest::binary>>), do: String.downcase(<<first>>) <> rest

  def convert_map_keys(map, conversion_function) when is_map(map) do
    map
    |> Enum.map(fn {key, value} ->
      {conversion_function.(key), convert_map_keys(value, conversion_function)}
    end)
    |> Enum.into(%{})
  end

  def convert_map_keys(list, conversion_function) when is_list(list) do
    Enum.map(list, &convert_map_keys(&1, conversion_function))
  end

  def convert_map_keys(value, _conversion_function), do: value
end
