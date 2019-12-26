defmodule HelloWorld do
  @moduledoc """
  Elixir counts the number of arguments as part of the function name.
  For instance;

      def hello() do
      end

  would be a completely different function from

      def hello(name) do
      end

  Can you find a way to make all the tests pass with just one
  function?

  Hint: look into argument defaults here:
  http://elixir-lang.org/getting-started/modules-and-functions.html#default-arguments
  """

  @doc """
  Greets the user by name, or by saying "Hello, World!"
  if no name is given.
  """

  @serifu "Hello"
  @default_name "World"
  @comma_sign ","
  @space_sign " "
  @exclamation_mark "!"

  def hello() do
    concat()
  end

  @spec hello(String.t) :: String.t
  def hello(name) do
    concat(name)
  end

  def concat(name \\ @default_name) do
    Enum.join([@serifu, @comma_sign, @space_sign, name, @exclamation_mark])
  end
end