defmodule SitsenseTest do
  use ExUnit.Case
  doctest Sitsense

  test "greets the world" do
    assert Sitsense.hello() == :world
  end
end
