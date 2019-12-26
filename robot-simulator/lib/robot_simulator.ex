defmodule RobotSimulator do
  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: any
  def create(direction \\ :north, position \\ {0, 0}) do
    with :ok <- validate_direction(direction),
         :ok <- validate_position(position),
         do: %{position: position, direction: direction}
  end

  defp validate_direction(direction) when direction in [:north, :east, :south, :west], do: :ok
  defp validate_direction(_), do: {:error, "invalid direction"}
  defp validate_position({x, y}) when is_number(x) and is_number(y), do: :ok
  defp validate_position(_), do: {:error, "invalid position"}
  defp validate_instructions(instructions)

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: any, instructions :: String.t()) :: any
  def simulate(robot, instructions) do
    instructions
    |> String.graphemes()
    |> Enum.reduce(robot, &move(&2, &1))
  end

  defp move(%{position: {x, y}, direction: :north} = robot, "A"),
    do: %{robot | position: {x, y + 1}}

  defp move(%{position: {x, y}, direction: :south} = robot, "A"),
    do: %{robot | position: {x, y - 1}}

  defp move(%{position: {x, y}, direction: :east} = robot, "A"),
    do: %{robot | position: {x + 1, y}}

  defp move(%{position: {x, y}, direction: :west} = robot, "A"),
    do: %{robot | position: {x - 1, y}}

  defp move(%{direction: :north} = robot, "L"), do: %{robot | direction: :west}
  defp move(%{direction: :south} = robot, "L"), do: %{robot | direction: :east}
  defp move(%{direction: :east} = robot, "L"), do: %{robot | direction: :north}
  defp move(%{direction: :west} = robot, "L"), do: %{robot | direction: :south}
  defp move(%{direction: :north} = robot, "R"), do: %{robot | direction: :east}
  defp move(%{direction: :south} = robot, "R"), do: %{robot | direction: :west}
  defp move(%{direction: :east} = robot, "R"), do: %{robot | direction: :south}
  defp move(%{direction: :west} = robot, "R"), do: %{robot | direction: :north}
  defp move(_, _), do: {:error, "invalid instruction"}

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction(robot), do: robot.direction

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: {integer, integer}
  def position(robot), do: robot.position
end
