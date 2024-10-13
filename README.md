# Morpheus

Morpheus is an Elixir library designed to seamlessly convert between `camelCase` and `snake_case` in Phoenix projects. It provides a simple and efficient way to transform map keys, making it easier to work with different naming conventions in your APIs.

## Features

- Convert map keys from `snake_case` to `camelCase` and vice versa
- Handle nested maps and lists
- Preserve atom and string key types
- Seamless integration with Phoenix for automatic conversion of JSON responses
- Plug for converting incoming request parameters from `camelCase` to `snake_case`
- Efficient and lightweight

## Installation

Add `morpheus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:morpheus, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get` to install the package.

## Configuration

To use Morpheus for automatic conversion of your Phoenix JSON responses, add the following to your `config/config.exs`:

```elixir
# This will already be present in your `config/config.exs` file
config :phoenix, :json_library, Jason

# Add this line below jason config
config :phoenix, :format_encoders, json: Morpheus.Config
```

This configuration tells Phoenix to use Morpheus for JSON encoding, which will automatically convert all outgoing JSON responses to `camelCase`.

## Usage

### Basic Usage

You can use Morpheus functions directly in your code:

```elixir
iex> Morpheus.snake_to_camel("user_name")
"userName"

iex> Morpheus.camel_to_snake("firstName")
"first_name"

iex> Morpheus.snake_to_camel(:user_email)
:userEmail

iex> Morpheus.convert_map_keys(%{user_name: "John", "last_login" => "2023-01-01"}, &Morpheus.snake_to_camel/1)
%{userName: "John", "lastLogin" => "2023-01-01"}
```

### Automatic Conversion in Phoenix

#### Outgoing Responses

With the configuration set up, Morpheus will automatically convert all your JSON responses. For example:

```elixir
defmodule MyApp.UserController do
  use MyApp, :controller

  def show(conn, %{"id" => id}) do
    user = %{
      user_id: id,
      first_name: "John",
      last_name: "Doe",
      email_address: "john.doe@example.com"
    }

    json(conn, user)
  end
end
```

The JSON response will be automatically converted to:

```json
{
  "userId": "1",
  "firstName": "John",
  "lastName": "Doe",
  "emailAddress": "john.doe@example.com"
}
```

#### Incoming Requests

Morpheus provides a plug to automatically convert incoming request parameters from `camelCase` to `snake_case`. To use this plug, add it to your router pipeline:

```elixir
defmodule MyApp.Router do
  use MyApp, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Morpheus.Plugs.SnakeCaseParams
  end

  scope "/api", MyApp do
    pipe_through :api
    # Your routes here
  end
end
```

This plug will convert all incoming parameters to `snake_case`. For example, if a client sends a request with `camelCase` parameters:

```json
{
  "userId": 1,
  "firstName": "John",
  "lastName": "Doe"
}
```

Your controller will receive these parameters in `snake_case`:

```elixir
def create(conn, params) do
  # params will be:
  # %{
  #   "user_id" => 1,
  #   "first_name" => "John",
  #   "last_name" => "Doe"
  # }
end
```

This allows you to work with `snake_case` in your Elixir code while maintaining `camelCase` in your API interface.

## Advanced Usage

### Handling Mixed Keys

Morpheus can handle maps with mixed key types:

```elixir
mixed_map = %{
  "user_name" => "John",
  "userEmail" => "john@example.com",
  1 => "first",
  nested: %{
    "last_login" => "2023-01-01",
    preferredLanguage: "en"
  },
  user_id: 1
}

converted = Morpheus.convert_map_keys(mixed_map, &Morpheus.snake_to_camel/1)
```

This will convert string and atom keys while leaving integer keys unchanged.

## Contributing

Contributions to Morpheus are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Write tests for your changes
4. Implement your changes
5. Run `mix test` to ensure all tests pass
6. Submit a pull request

Please make sure to update tests as appropriate and adhere to the Elixir style guide.

## License

Morpheus is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Morpheus is developed and maintained by Dinesh Anbazhagan. You can reach out with any questions or feedback.

---

We hope Morpheus helps simplify your work with different naming conventions in your Phoenix projects. Happy coding!
