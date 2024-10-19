defmodule Morpheus.EncoderTest do
  use ExUnit.Case, async: true
  alias Morpheus.Encoder

  defp assert_encoding(input, expected) do
    assert expected ==
             input
             |> Encoder.encode()
             |> Jason.decode!()
  end

  defp assert_encoding_to_iodata!(input, expected) do
    assert expected ==
             input
             |> Encoder.encode_to_iodata!()
             |> IO.iodata_to_binary()
             |> Jason.decode!()
  end

  describe "encode/2" do
    test "encodes simple map with atom and string keys" do
      atom_input = %{user_name: "John Doe", age: 30}
      string_input = %{"user_name" => "John Doe", "age" => 30}
      expected = %{"userName" => "John Doe", "age" => 30}

      assert_encoding(atom_input, expected)
      assert_encoding(string_input, expected)
    end

    test "encodes nested structures with atom and string keys" do
      atom_input = %{
        user_info: %{
          first_name: "John",
          last_name: "Doe",
          address: %{
            street_name: "Main St",
            city_name: "New York"
          }
        },
        posts: [%{post_id: 1, post_title: "Hello"}, %{post_id: 2, post_title: "World"}]
      }

      string_input = %{
        "user_info" => %{
          "first_name" => "John",
          "last_name" => "Doe",
          "address" => %{
            "street_name" => "Main St",
            "city_name" => "New York"
          }
        },
        "posts" => [
          %{"post_id" => 1, "post_title" => "Hello"},
          %{"post_id" => 2, "post_title" => "World"}
        ]
      }

      expected = %{
        "userInfo" => %{
          "firstName" => "John",
          "lastName" => "Doe",
          "address" => %{
            "streetName" => "Main St",
            "cityName" => "New York"
          }
        },
        "posts" => [
          %{"postId" => 1, "postTitle" => "Hello"},
          %{"postId" => 2, "postTitle" => "World"}
        ]
      }

      assert_encoding(atom_input, expected)
      assert_encoding(string_input, expected)
    end

    test "encodes list of maps with atom and string keys" do
      atom_input = [%{user_id: 1, user_name: "John"}, %{user_id: 2, user_name: "Jane"}]

      string_input = [
        %{"user_id" => 1, "user_name" => "John"},
        %{"user_id" => 2, "user_name" => "Jane"}
      ]

      expected = [%{"userId" => 1, "userName" => "John"}, %{"userId" => 2, "userName" => "Jane"}]

      assert_encoding(atom_input, expected)
      assert_encoding(string_input, expected)
    end

    test "preserves camelCase keys and handles mixed snake_case and camelCase keys" do
      inputs = [
        %{userName: "John Doe", userAge: 30},
        %{"userName" => "John Doe", "userAge" => 30},
        %{userName: "John Doe", user_age: 30},
        %{"userName" => "John Doe", "user_age" => 30}
      ]

      expected = %{"userName" => "John Doe", "userAge" => 30}

      Enum.each(inputs, fn input ->
        assert_encoding(input, expected)
      end)
    end

    test "encodes mixed string and atom keys" do
      input = %{:user_name => "John Doe", "userAge" => 30}
      expected = %{"userName" => "John Doe", "userAge" => 30}

      assert_encoding(input, expected)
    end

    test "encodes complex nested structure with mixed keys" do
      input = %{
        user_info: %{
          personal: %{"first_name" => "John", "last_name" => "Doe"},
          contactInfo: %{
            email: "john@example.com",
            phone_numbers: ["123-456-7890", "987-654-3210"]
          },
          preferences: %{
            "notification_settings" => %{email: true, push: false},
            newsletter: true,
            theme: "dark"
          }
        },
        posts: [
          %{post_id: 1, post_title: "Hello", tags: ["greeting", "first_post"]},
          %{post_id: 2, post_title: "World", tags: ["earth", "second_post"]}
        ]
      }

      expected = %{
        "userInfo" => %{
          "personal" => %{"firstName" => "John", "lastName" => "Doe"},
          "contactInfo" => %{
            "email" => "john@example.com",
            "phoneNumbers" => ["123-456-7890", "987-654-3210"]
          },
          "preferences" => %{
            "notificationSettings" => %{"email" => true, "push" => false},
            "newsletter" => true,
            "theme" => "dark"
          }
        },
        "posts" => [
          %{"postId" => 1, "postTitle" => "Hello", "tags" => ["greeting", "first_post"]},
          %{"postId" => 2, "postTitle" => "World", "tags" => ["earth", "second_post"]}
        ]
      }

      assert_encoding(input, expected)
    end

    test "encodes non-map values" do
      assert Encoder.encode(42) == "42"
      assert Encoder.encode("hello") == "\"hello\""
      assert Encoder.encode(true) == "true"
    end

    test "encodes empty map and list" do
      assert Encoder.encode(%{}) == "{}"
      assert Encoder.encode([]) == "[]"
    end

    test "encodes map with nil values" do
      atom_input = %{user_name: "John Doe", user_age: nil}
      string_input = %{"user_name" => "John Doe", "user_age" => nil}
      expected = %{"userName" => "John Doe", "userAge" => nil}

      assert_encoding(atom_input, expected)
      assert_encoding(string_input, expected)
    end

    test "respects additional Jason encoding options" do
      input = %{user_name: "John Doe", user_age: 30}
      expected = "{\n  \"userName\": \"John Doe\",\n  \"userAge\": 30\n}"

      assert expected == Encoder.encode(input, pretty: true)
    end
  end

  describe "encode_to_iodata!/1" do
    test "encodes simple map with atom and string keys" do
      atom_input = %{user_name: "John Doe", age: 30}
      string_input = %{"user_name" => "John Doe", "age" => 30}
      expected = %{"userName" => "John Doe", "age" => 30}

      assert_encoding_to_iodata!(atom_input, expected)
      assert_encoding_to_iodata!(string_input, expected)
    end

    test "encodes nested structures with atom and string keys" do
      atom_input = %{
        user_info: %{
          first_name: "John",
          last_name: "Doe",
          address: %{
            street_name: "Main St",
            city_name: "New York"
          }
        },
        posts: [%{post_id: 1, post_title: "Hello"}, %{post_id: 2, post_title: "World"}]
      }

      string_input = %{
        "user_info" => %{
          "first_name" => "John",
          "last_name" => "Doe",
          "address" => %{
            "street_name" => "Main St",
            "city_name" => "New York"
          }
        },
        "posts" => [
          %{"post_id" => 1, "post_title" => "Hello"},
          %{"post_id" => 2, "post_title" => "World"}
        ]
      }

      expected = %{
        "userInfo" => %{
          "firstName" => "John",
          "lastName" => "Doe",
          "address" => %{
            "streetName" => "Main St",
            "cityName" => "New York"
          }
        },
        "posts" => [
          %{"postId" => 1, "postTitle" => "Hello"},
          %{"postId" => 2, "postTitle" => "World"}
        ]
      }

      assert_encoding_to_iodata!(atom_input, expected)
      assert_encoding_to_iodata!(string_input, expected)
    end

    test "encodes list of maps with atom and string keys" do
      atom_input = [%{user_id: 1, user_name: "John"}, %{user_id: 2, user_name: "Jane"}]

      string_input = [
        %{"user_id" => 1, "user_name" => "John"},
        %{"user_id" => 2, "user_name" => "Jane"}
      ]

      expected = [%{"userId" => 1, "userName" => "John"}, %{"userId" => 2, "userName" => "Jane"}]

      assert_encoding_to_iodata!(atom_input, expected)
      assert_encoding_to_iodata!(string_input, expected)
    end

    test "preserves camelCase keys and handles mixed snake_case and camelCase keys" do
      inputs = [
        %{userName: "John Doe", userAge: 30},
        %{"userName" => "John Doe", "userAge" => 30},
        %{userName: "John Doe", user_age: 30},
        %{"userName" => "John Doe", "user_age" => 30}
      ]

      expected = %{"userName" => "John Doe", "userAge" => 30}

      Enum.each(inputs, fn input ->
        assert_encoding_to_iodata!(input, expected)
      end)
    end

    test "encodes mixed string and atom keys" do
      input = %{:user_name => "John Doe", "userAge" => 30}
      expected = %{"userName" => "John Doe", "userAge" => 30}

      assert_encoding_to_iodata!(input, expected)
    end

    test "encodes complex nested structure with mixed keys" do
      input = %{
        user_info: %{
          personal: %{"first_name" => "John", "last_name" => "Doe"},
          contactInfo: %{
            email: "john@example.com",
            phone_numbers: ["123-456-7890", "987-654-3210"]
          },
          preferences: %{
            "notification_settings" => %{email: true, push: false},
            newsletter: true,
            theme: "dark"
          }
        },
        posts: [
          %{post_id: 1, post_title: "Hello", tags: ["greeting", "first_post"]},
          %{post_id: 2, post_title: "World", tags: ["earth", "second_post"]}
        ]
      }

      expected = %{
        "userInfo" => %{
          "personal" => %{"firstName" => "John", "lastName" => "Doe"},
          "contactInfo" => %{
            "email" => "john@example.com",
            "phoneNumbers" => ["123-456-7890", "987-654-3210"]
          },
          "preferences" => %{
            "notificationSettings" => %{"email" => true, "push" => false},
            "newsletter" => true,
            "theme" => "dark"
          }
        },
        "posts" => [
          %{"postId" => 1, "postTitle" => "Hello", "tags" => ["greeting", "first_post"]},
          %{"postId" => 2, "postTitle" => "World", "tags" => ["earth", "second_post"]}
        ]
      }

      assert_encoding_to_iodata!(input, expected)
    end

    test "encodes non-map values" do
      assert "42" == 42 |> Encoder.encode_to_iodata!() |> IO.iodata_to_binary()
      assert "\"hello\"" == "hello" |> Encoder.encode_to_iodata!() |> IO.iodata_to_binary()
      assert "true" == true |> Encoder.encode_to_iodata!() |> IO.iodata_to_binary()
    end

    test "encodes empty map and list" do
      assert "{}" == %{} |> Encoder.encode_to_iodata!() |> IO.iodata_to_binary()
      assert "[]" == [] |> Encoder.encode_to_iodata!() |> IO.iodata_to_binary()
    end

    test "encodes map with nil values" do
      atom_input = %{user_name: "John Doe", user_age: nil}
      string_input = %{"user_name" => "John Doe", "user_age" => nil}
      expected = %{"userName" => "John Doe", "userAge" => nil}

      assert_encoding_to_iodata!(atom_input, expected)
      assert_encoding_to_iodata!(string_input, expected)
    end
  end
end
