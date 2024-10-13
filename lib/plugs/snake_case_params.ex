defmodule Morpheus.Plugs.SnakeCaseParams do
  @moduledoc """
  A plug to convert incoming request parameters from camelCase to snake_case.

  This plug automatically converts all keys in the request parameters from camelCase
  to snake_case format. It handles nested maps and lists.

  ## Usage

  Add this plug to your router pipeline:

  ```elixir
  pipeline :api do
    plug :accepts, ["json"]
    plug Morpheus.Plugs.SnakeCaseParams
  end
  ```
  """

  def init(opts), do: opts

  def call(%{params: params} = conn, _opts) do
    params = Morpheus.convert_map_keys(params, &Morpheus.camel_to_snake/1)
    %{conn | params: params}
  end
end
