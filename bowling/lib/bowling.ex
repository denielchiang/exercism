defmodule Bowling do
  defstruct [:frames]

  # bowling basic params
  @spare_score 10
  @strike_rolling_score 10
  @max_pin_count 10
  @min_pin_count 0
  @normal_frame_count 9

  # status
  @strike :strike
  @spare :spare
  @open :open
  @normal :normal
  @tenth_1 :fill_1
  @tenth_2 :fill_2
  @tenth_3 :fill_3

  # error message
  @negative_roll_msg {:error, "Negative roll is invalid"}
  @pin_count_exceed_msg {:error, "Pin count exceeds pins on the lane"}
  @not_finish_game_msg {:error, "Score cannot be taken until the end of the game"}
  @game_set_msg {:error, "Cannot roll after game is over"}

  @doc """
  Creates a new game of bowling that can be used to store the results of
  the game
  """

  @spec start() :: any
  def start, do: %Bowling{frames: []}

  @doc """
  Records the number of pins knocked down on a single roll. Returns `any`
  unless there is something wrong with the given number of pins, in which
  case it returns a helpful message.
  """
  @spec roll(any, integer) :: any | String.t()
  def roll(_game, roll) when roll < @min_pin_count, do: @negative_roll_msg
  def roll(_game, roll) when roll > @max_pin_count, do: @pin_count_exceed_msg

  def roll(%Bowling{frames: [%{score: score, status: @open} | _]}, roll)
      when score + roll > @max_pin_count,
      do: @pin_count_exceed_msg

  def roll(
        %Bowling{frames: [%{score: score, status: @tenth_2}, %{score: tenth_1_score} | _]},
        roll
      )
      when tenth_1_score == @max_pin_count and score < @max_pin_count and
             score + roll > @max_pin_count,
      do: @pin_count_exceed_msg

  def roll(%Bowling{frames: [%{status: @tenth_3} | _]}, _roll), do: @game_set_msg

  def roll(
        %Bowling{
          frames: [%{score: tenth_2_score, status: @tenth_2}, %{score: tenth_1_score} | _]
        },
        _roll
      )
      when tenth_1_score + tenth_2_score < @max_pin_count,
      do: @game_set_msg

  def roll(%Bowling{frames: frames}, roll) do
    %Bowling{
      frames: frames |> is_noraml_frame_done?() |> set_score(frames, roll)
    }
  end

  defp set_score(true, frames, roll), do: set_tenth_frame(frames, roll)

  defp set_score(false, frames, roll), do: set_normal_frame(frames, roll)

  # 10th frame
  defp set_tenth_frame([%{status: @strike}, %{status: @strike} | _] = frames, roll),
    do: [set_tenth_1_roll(roll, roll, roll) | frames]

  defp set_tenth_frame([%{status: @normal}, %{status: @strike} | _] = frames, roll),
    do: [set_tenth_1_roll(roll, roll) | frames]

  defp set_tenth_frame([%{status: @normal} | _] = frames, roll),
    do: [set_tenth_1_roll(roll) | frames]

  defp set_tenth_frame([%{status: @strike} | _] = frames, roll),
    do: [set_tenth_1_roll(roll, roll) | frames]

  defp set_tenth_frame([%{status: @spare} | _] = frames, roll),
    do: [set_tenth_1_roll(roll, roll) | frames]

  defp set_tenth_frame([%{status: @tenth_1}, %{status: @strike} | _] = frames, roll),
    do: [set_tenth_2_roll(roll, roll) | frames]

  defp set_tenth_frame([%{status: @tenth_1} | _] = frames, roll),
    do: [set_tenth_2_roll(roll) | frames]

  defp set_tenth_frame([%{status: @tenth_2} | _] = frames, roll),
    do: [set_tenth_3_roll(roll) | frames]

  # turkey
  defp set_normal_frame([%{status: @strike}, %{status: @strike} | _] = frames, roll)
       when roll == @strike_rolling_score,
       do: [set_strike_roll(roll, roll) | frames]

  # last 2 roll was strike
  defp set_normal_frame([%{status: _any}, %{status: @strike} | _] = frames, roll)
       when roll == @strike_rolling_score,
       do: [set_strike_roll(roll) | frames]

  # 2 strikes
  defp set_normal_frame([%{status: @strike} | _] = frames, roll)
       when roll == @strike_rolling_score,
       do: [set_strike_roll(roll) | frames]

  # This roll is strike but last one is normal
  defp set_normal_frame([%{status: @normal} | _] = frames, roll)
       when roll == @strike_rolling_score,
       do: [set_strike_roll() | frames]

  # last one is open but last 2 was strike and this roll make it to spare
  defp set_normal_frame([%{score: score, status: @open}, %{status: @strike} | _] = frames, roll)
       when score + roll == @spare_score,
       do: [set_spare_roll(roll, roll) | frames]

  # last one is open and this roll make it to spare
  defp set_normal_frame([%{score: score, status: @open} | _] = frames, roll)
       when score + roll == @spare_score,
       do: [set_spare_roll(roll) | frames]

  defp set_normal_frame([%{status: @open}, %{status: @strike} | _] = frames, roll),
    do: [set_normal_roll(roll, roll) | frames]

  # last one is open this one is normal
  defp set_normal_frame([%{status: @open} | _] = frames, roll),
    do: [set_normal_roll(roll) | frames]

  # last 2 roll was strike
  defp set_normal_frame([%{status: @strike}, %{status: @strike} | _] = frames, roll),
    do: [set_open_roll(roll, roll, roll) | frames]

  # Last roll was strike but this one is open
  defp set_normal_frame([%{status: @strike} | _] = frames, roll),
    do: [set_open_roll(roll, roll) | frames]

  # last roll was spare this one is open
  defp set_normal_frame([%{status: @spare} | _] = frames, roll),
    do: [set_open_roll(roll, roll) | frames]

  # last one is normal this one is open
  defp set_normal_frame([%{status: @normal} | _] = frames, roll),
    do: [set_open_roll(roll) | frames]

  # first rolling and its strike
  defp set_normal_frame(_frames, roll) when roll == @strike_rolling_score, do: [set_strike_roll()]
  # first rolling and its not strike
  defp set_normal_frame(_frames, roll), do: [set_open_roll(roll)]

  defp set_strike_roll, do: %{score: 10, status: @strike, bonus: []}
  defp set_strike_roll(bonus), do: %{score: 10, status: @strike, bonus: [bonus]}

  defp set_strike_roll(bonus, strike_bonus),
    do: %{score: 10, status: @strike, bonus: [bonus, strike_bonus]}

  defp set_spare_roll(roll), do: %{score: roll, status: @spare, bonus: []}
  defp set_spare_roll(roll, bonus), do: %{score: roll, status: @spare, bonus: [bonus]}
  defp set_open_roll(roll), do: %{score: roll, status: @open, bonus: []}
  defp set_open_roll(roll, bonus), do: %{score: roll, status: @open, bonus: [bonus]}

  defp set_open_roll(roll, bonus, strike_bonus),
    do: %{score: roll, status: @open, bonus: [bonus, strike_bonus]}

  defp set_normal_roll(roll), do: %{score: roll, status: @normal, bonus: []}
  defp set_normal_roll(roll, bonus), do: %{score: roll, status: @normal, bonus: [bonus]}

  defp set_tenth_1_roll(roll), do: %{score: roll, status: @tenth_1, bonus: []}
  defp set_tenth_1_roll(roll, bonus), do: %{score: roll, status: @tenth_1, bonus: [bonus]}

  defp set_tenth_1_roll(roll, bonus, strike_bonus),
    do: %{score: roll, status: @tenth_1, bonus: [bonus, strike_bonus]}

  defp set_tenth_2_roll(roll), do: %{score: roll, status: @tenth_2, bonus: []}
  defp set_tenth_2_roll(roll, bonus), do: %{score: roll, status: @tenth_2, bonus: [bonus]}

  defp set_tenth_3_roll(roll), do: %{score: roll, status: @tenth_3, bonus: []}

  defp is_noraml_frame_done?(frames),
    do:
      frames |> Enum.filter(&(&1.status in not_last_frame_status())) |> Enum.count() ==
        @normal_frame_count

  defp not_last_frame_status, do: [@strike, @normal, @spare]

  defp is_game_finished?([%{score: tenth_2_score, status: @tenth_2}, %{score: tenth_1_score} | _])
       when tenth_1_score + tenth_2_score < @max_pin_count,
       do: true

  defp is_game_finished?([%{status: @tenth_3} | _]), do: true

  defp is_game_finished?(_frames), do: false

  @doc """
  Returns the score of a given game of bowling if the game is complete.
  If the game isn't complete, it returns a helpful message.
  """

  @spec score(any) :: integer | String.t()
  def score(%Bowling{frames: frames}) do
    frames
    |> is_game_finished?()
    |> cal_score(frames)
  end

  defp cal_score(true, frames) do
    bonus_total = frames |> Enum.map(&sum_bonus/1) |> Enum.sum()
    score_total = frames |> Enum.map(& &1.score) |> Enum.sum()
    bonus_total + score_total
  end

  defp cal_score(false, _frames), do: @not_finish_game_msg

  defp sum_bonus(%{bonus: []}), do: 0
  defp sum_bonus(%{bonus: bonus}), do: Enum.sum(bonus)
end
