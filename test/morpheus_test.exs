defmodule MorpheusTest do
  use ExUnit.Case
  doctest Morpheus

  test "greets the world" do
    assert Morpheus.hello() == :world
  end
end
