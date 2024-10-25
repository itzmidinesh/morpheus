defmodule MorpheusTest do
  use ExUnit.Case, async: true
  doctest Morpheus

  describe "camel_to_snake/1" do
    test "converts simple camelCase string to snake_case" do
      assert Morpheus.camel_to_snake("userFirstName") == "user_first_name"
    end

    test "handles strings starting with uppercase" do
      assert Morpheus.camel_to_snake("UserFirstName") == "user_first_name"
    end

    test "handles uppercase words" do
      assert Morpheus.camel_to_snake("API") == "api"
    end

    test "preserves consecutive uppercase letters" do
      assert Morpheus.camel_to_snake("APIResponse") == "api_response"
    end

    test "handles single lowercase letter" do
      assert Morpheus.camel_to_snake("iOS") == "i_os"
    end

    test "preserves existing snake_case" do
      assert Morpheus.camel_to_snake("user_first_name") == "user_first_name"
    end

    test "converts atoms" do
      assert Morpheus.camel_to_snake(:userFirstName) == :user_first_name
    end

    test "handles strings starting with underscore" do
      assert Morpheus.camel_to_snake("_userName") == "_user_name"
    end

    test "leaves other types unchanged" do
      assert Morpheus.camel_to_snake(123) == 123
      assert Morpheus.camel_to_snake([1, 2, 3]) == [1, 2, 3]
    end
  end

  describe "snake_to_camel/1" do
    test "converts simple snake_case string to camelCase" do
      assert Morpheus.snake_to_camel("user_first_name") == "userFirstName"
    end

    test "handles strings with consecutive underscores" do
      assert Morpheus.snake_to_camel("user__first__name") == "userFirstName"
    end

    test "preserves existing camelCase" do
      assert Morpheus.snake_to_camel("userFirstName") == "userFirstName"
    end

    test "handles uppercase acronyms" do
      assert Morpheus.snake_to_camel("API_response") == "apiResponse"
    end

    test "handles uppercase words" do
      assert Morpheus.snake_to_camel("API") == "api"
    end

    test "converts atoms" do
      assert Morpheus.snake_to_camel(:user_first_name) == :userFirstName
    end

    test "handles strings starting with underscore" do
      assert Morpheus.snake_to_camel("_user_first_name") == "userFirstName"
    end

    test "leaves other types unchanged" do
      assert Morpheus.snake_to_camel(123) == 123
      assert Morpheus.snake_to_camel([1, 2, 3]) == [1, 2, 3]
    end
  end

  describe "convert_map_keys/2" do
    test "converts keys in a simple map" do
      input = %{"user_name" => "John", "user_age" => 30}
      expected = %{"userName" => "John", "userAge" => 30}
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "handles nested maps" do
      input = %{"user_info" => %{"first_name" => "John", "last_name" => "Doe"}}
      expected = %{"userInfo" => %{"firstName" => "John", "lastName" => "Doe"}}
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "handles nested lists of maps" do
      input = %{"users" => [%{"user_id" => 1, "addresses" => [%{"street_name" => "Main St"}]}]}
      expected = %{"users" => [%{"userId" => 1, "addresses" => [%{"streetName" => "Main St"}]}]}
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "converts keys in a list of maps" do
      input = [%{"user_id" => 1, "user_name" => "John"}, %{"user_id" => 2, "user_name" => "Jane"}]
      expected = [%{"userId" => 1, "userName" => "John"}, %{"userId" => 2, "userName" => "Jane"}]
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "preserves non-map values" do
      input = %{"numbers" => [1, 2, 3], "active" => true}
      expected = %{"numbers" => [1, 2, 3], "active" => true}
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "handles atom keys" do
      input = %{user_name: "John", user_age: 30}
      expected = %{userName: "John", userAge: 30}
      assert Morpheus.convert_map_keys(input, &Morpheus.snake_to_camel/1) == expected
    end

    test "leaves non-map/list values unchanged" do
      assert Morpheus.convert_map_keys("not_a_map", &Morpheus.snake_to_camel/1) == "not_a_map"
      assert Morpheus.convert_map_keys(123, &Morpheus.snake_to_camel/1) == 123
    end

    test "handles empty maps and lists" do
      assert Morpheus.convert_map_keys(%{}, &Morpheus.snake_to_camel/1) == %{}
      assert Morpheus.convert_map_keys([], &Morpheus.snake_to_camel/1) == []
      assert Morpheus.convert_map_keys(%{}, &Morpheus.camel_to_snake/1) == %{}
      assert Morpheus.convert_map_keys([], &Morpheus.camel_to_snake/1) == []
    end
  end
end
