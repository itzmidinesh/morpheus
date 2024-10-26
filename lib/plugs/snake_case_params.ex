defmodule Morpheus.Plugs.SnakeCaseParams do
  @moduledoc """
  A Phoenix plug that converts incoming request parameters from camelCase to snake_case.

  Automatically converts parameter keys in incoming requests to match Elixir's snake_case
  convention, letting you work with consistent naming in your Phoenix controllers.

  ## Setup

  Add to your router pipeline:

      pipeline :api do
        plug :accepts, ["json"]
        plug Morpheus.Plugs.SnakeCaseParams
      end

  ## Example

      # Incoming request with params:
      %{
        "userName" => "john_doe",
        "userProfile" => %{
          "firstName" => "John",
          "lastName" => "Doe"
        }
      }

      # Parameters in your controller:
      %{
        "user_name" => "john_doe",
        "user_profile" => %{
          "first_name" => "John",
          "last_name" => "Doe"
        }
      }

  ## Key Features

    * Recursive conversion of nested maps and lists
    * Works with both query parameters and request body
    * Converts all parameter keys while preserving values
    * Zero configuration required

  ## Important Notes

    * All camelCase keys will be converted to snake_case
    * The conversion modifies the `params` field of the connection
    * If you need to preserve certain camelCase keys, handle them separately in your controller
  """

  @doc """
  Initializes the plug with the given options.

  Called at compile time. Currently accepts options for future extensibility.

  ## Parameters

    * `opts` - A keyword list of options (currently unused)

  ## Returns

  Returns the options unchanged.
  """
  def init(opts), do: opts

  @doc """
  Converts connection parameters from camelCase to snake_case.

  Called at runtime for each request. Processes both URL query parameters
  and request body parameters.

  ## Parameters

    * `conn` - The `Plug.Conn` struct for the current connection
    * `_opts` - Options from `init/1` (currently unused)

  ## Returns

  Returns the updated connection with converted parameters.

  ## Examples

      # Basic parameter conversion
      # Given a request to "/users?userName=john"
      conn = Morpheus.Plugs.SnakeCaseParams.call(conn, [])
      conn.params
      #=> %{"user_name" => "john"}

      # Nested parameter conversion
      # Given a POST with JSON: {"userProfile": {"firstName": "John"}}
      conn = Morpheus.Plugs.SnakeCaseParams.call(conn, [])
      conn.params
      #=> %{"user_profile" => %{"first_name" => "John"}}
  """
  def call(%{params: params} = conn, _opts) do
    params = Morpheus.convert_map_keys(params, &Morpheus.camel_to_snake/1)
    %{conn | params: params}
  end
end
