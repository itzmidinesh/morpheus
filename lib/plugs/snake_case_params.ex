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

  ## Behavior

  - The plug converts all parameter keys recursively, including those in nested maps and lists.
  - It does not modify the values of the parameters, only the keys.
  - The conversion is done in-place, modifying the `params` field of the connection.

  ## Limitations

  - This plug assumes that all camelCase keys should be converted. If you have keys that
    should remain in camelCase, you may need to handle those cases separately.
  """

  @doc """
  Initializes the plug with the given options.

  This function is called at compile time and allows for configuration of the plug.
  Currently, it doesn't use any options but is included for future extensibility.

  ## Parameters

    * `opts` - A keyword list of options (currently unused).

  ## Returns

  Returns the options unchanged.
  """
  def init(opts), do: opts

  @doc """
  Converts the keys in the connection's params from camelCase to snake_case.

  This function is called at runtime for each request that goes through the plug.

  ## Parameters

    * `conn` - The `Plug.Conn` struct representing the current connection.
    * `_opts` - The options returned by `init/1` (currently unused).

  ## Returns

  Returns the updated `conn` struct with modified `params`.

  ## Examples

      # Assuming a request with params: %{"userName" => "John", "userAge" => 30}
      conn = Morpheus.Plugs.SnakeCaseParams.call(conn, [])
      # conn.params will now be %{"user_name" => "John", "user_age" => 30}

  """
  def call(%{params: params} = conn, _opts) do
    params = Morpheus.convert_map_keys(params, &Morpheus.camel_to_snake/1)
    %{conn | params: params}
  end
end
