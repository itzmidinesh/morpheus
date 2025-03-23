defmodule Morpheus.Plugs.SnakeCaseParamsTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias Morpheus.Plugs.SnakeCaseParams

  describe "init/1" do
    test "returns options unchanged" do
      opts = [some: "option"]
      assert SnakeCaseParams.init(opts) == opts
    end
  end

  describe "call/2" do
    test "converts simple camelCase string to snake_case" do
      conn = conn(:post, "/", %{"firstName" => "John", "lastName" => "Doe", "userAge" => 30})
      conn = SnakeCaseParams.call(conn, [])
      assert conn.params == %{"first_name" => "John", "last_name" => "Doe", "user_age" => 30}
    end

    test "handles nested maps with camelCase keys" do
      conn =
        conn(:post, "/", %{
          "userInfo" => %{
            "firstName" => "John",
            "lastName" => "Doe",
            "contactInfo" => %{
              "emailAddress" => "john@example.com",
              "phoneNumber" => "123-456-7890"
            }
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_info" => %{
                 "first_name" => "John",
                 "last_name" => "Doe",
                 "contact_info" => %{
                   "email_address" => "john@example.com",
                   "phone_number" => "123-456-7890"
                 }
               }
             }
    end

    test "handles list of maps with camelCase keys" do
      conn =
        conn(:post, "/", %{
          "userList" => [
            %{"userId" => 1, "firstName" => "John"},
            %{"userId" => 2, "firstName" => "Jane"}
          ]
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_list" => [
                 %{"user_id" => 1, "first_name" => "John"},
                 %{"user_id" => 2, "first_name" => "Jane"}
               ]
             }
    end

    test "preserves non-string values while ensuring string keys" do
      conn =
        conn(:post, "/", %{
          "userData" => %{
            "1" => "first",
            "symbolKey" => "value",
            "mixedData" => [1, true, nil, "string"]
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_data" => %{
                 "1" => "first",
                 "symbol_key" => "value",
                 "mixed_data" => [1, true, nil, "string"]
               }
             }
    end

    test "handles empty maps and lists" do
      conn =
        conn(:post, "/", %{
          "emptyMap" => %{},
          "emptyList" => [],
          "nestedEmptyMap" => %{
            "emptyMap" => %{},
            "emptyList" => []
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "empty_map" => %{},
               "empty_list" => [],
               "nested_empty_map" => %{
                 "empty_map" => %{},
                 "empty_list" => []
               }
             }
    end

    test "preserves existing snake_case keys" do
      conn =
        conn(:post, "/", %{
          "firstName" => "John",
          "lastName" => "Doe",
          "user_age" => 30,
          "contact_info" => %{
            "email_address" => "john@example.com",
            "phoneNumber" => "123-456-7890"
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "first_name" => "John",
               "last_name" => "Doe",
               "user_age" => 30,
               "contact_info" => %{
                 "email_address" => "john@example.com",
                 "phone_number" => "123-456-7890"
               }
             }
    end

    test "handles deeply nested structures" do
      conn =
        conn(:post, "/", %{
          "userData" => %{
            "personalInfo" => %{
              "nameDetails" => %{
                "firstName" => "John",
                "lastName" => "Doe"
              },
              "addressDetails" => [
                %{"streetName" => "Main St", "cityName" => "NYC"},
                %{"streetName" => "Broadway", "cityName" => "LA"}
              ]
            },
            "accountSettings" => %{
              "emailPreferences" => %{
                "dailyNewsletter" => true,
                "weeklyDigest" => false
              }
            }
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_data" => %{
                 "personal_info" => %{
                   "name_details" => %{
                     "first_name" => "John",
                     "last_name" => "Doe"
                   },
                   "address_details" => [
                     %{"street_name" => "Main St", "city_name" => "NYC"},
                     %{"street_name" => "Broadway", "city_name" => "LA"}
                   ]
                 },
                 "account_settings" => %{
                   "email_preferences" => %{
                     "daily_newsletter" => true,
                     "weekly_digest" => false
                   }
                 }
               }
             }
    end

    test "handles nil values in maps" do
      conn =
        conn(:post, "/", %{
          "userData" => nil,
          "userInfo" => %{"firstName" => nil},
          "contactData" => %{
            "emailAddress" => nil,
            "phoneNumber" => "123-456-7890"
          }
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_data" => nil,
               "user_info" => %{"first_name" => nil},
               "contact_data" => %{
                 "email_address" => nil,
                 "phone_number" => "123-456-7890"
               }
             }
    end

    test "handles single-letter camelCase keys" do
      conn =
        conn(:post, "/", %{
          "aField" => "value",
          "bData" => "test",
          "userData" => %{"xPos" => 1, "yPos" => 2}
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "a_field" => "value",
               "b_data" => "test",
               "user_data" => %{"x_pos" => 1, "y_pos" => 2}
             }
    end

    test "handles special characters in keys" do
      conn =
        conn(:post, "/", %{
          "user@Info" => "value",
          "user-Name" => "test",
          "user.Data" => "data"
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user@info" => "value",
               "user-name" => "test",
               "user.data" => "data"
             }
    end

    test "handles unexpected input types" do
      conn =
        conn(:post, "/", %{
          "" => "empty key",
          " spacedKey" => "spaced value",
          "normalKey" => "normal value"
        })

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "" => "empty key",
               " spaced_key" => "spaced value",
               "normal_key" => "normal value"
             }
    end

    test "converts query params to snake_case" do
      conn =
        conn(:get, "/?firstName=John&lastName=Doe&userAge=30")
        |> Plug.Conn.fetch_query_params()

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "first_name" => "John",
               "last_name" => "Doe",
               "user_age" => "30"
             }
    end

    test "handles query params with arrays" do
      conn =
        conn(:get, "/?userIds[]=1&userIds[]=2&userInfo[firstName]=John")
        |> Plug.Conn.fetch_query_params()

      conn = SnakeCaseParams.call(conn, [])

      assert conn.params == %{
               "user_ids" => ["1", "2"],
               "user_info" => %{"first_name" => "John"}
             }
    end
  end
end
