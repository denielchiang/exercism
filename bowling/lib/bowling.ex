defmodule Bowling do
  defstruct [:score, :pending, :roll_count]

  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  @spec start() :: any
  def start do
    %Bowling{score: 0, pending: [], roll_count: 0}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """
  @spec roll(any, integer) :: any | String.t()
  def roll(game, roll) do
    game
    |> bonus(roll)
    |> IO.inspect()
    |> add_roll_count()
  end

  @spare_score 10
  @frame_rolls 2
  @last_frame_roll 19..21

  defp add_roll_count(%Bowling{roll_count: roll_count} = game),
    do: %Bowling{game | roll_count: roll_count + 1}

  # last frame don't count bonus
  defp bonus(%Bowling{roll_count: roll_count} = game, roll)
       when roll_count in @last_frame_roll,
       do: %Bowling{game | score: game.score + roll, pending: []}

  defp bonus(%Bowling{score: score, pending: [10, extra_roll_1, extra_roll_2]} = game, roll) do
    %Bowling{game | score: score + 2 * (extra_roll_1 + extra_roll_2)}
  end

  defp bonus(%Bowling{score: score, pending: pending} = game, roll)
       when length(pending) == @frame_rolls do
    sum_score = pending |> Enum.sum()

    if sum_score == @spare_score do
      %Bowling{game | score: game.score + 2 * roll, pending: [roll]}
    else
      %Bowling{game | score: game.score + roll, pending: [roll]}
    end
  end

  defp bonus(%Bowling{score: score, pending: pending} = game, roll),
    do: %Bowling{game | score: game.score + roll, pending: [roll | pending] |> Enum.reverse()}

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(any) :: integer | String.t()
  def score(game) do
    game.score
  end
end
