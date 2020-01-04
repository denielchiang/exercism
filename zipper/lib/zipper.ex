defmodule Zipper do
  alias BinTree, as: BT

  defstruct [:data, :path, :dirs]

  @doc """
  Get a zipper focused on the root node.
  """
  @spec from_tree(BinTree.t()) :: Zipper.t()
  def from_tree(bin_tree), do: %Zipper{data: bin_tree, path: [bin_tree], dirs: []}

  @doc """
  Get the complete tree from a zipper.
  """
  @spec to_tree(Zipper.t()) :: BinTree.t()
  def to_tree(zipper), do: zipper.data

  @doc """
  Get the value of the focus node.
  """
  @spec value(Zipper.t()) :: any
  def value(%Zipper{path: [last_appended | _tail]}), do: last_appended.value

  @doc """
  Get the left child of the focus node, if any.
  """
  @spec left(Zipper.t()) :: Zipper.t() | nil
  def left(%Zipper{path: [%BT{left: nil} | _tail]}), do: nil

  def left(%Zipper{path: [%BT{left: l_value} | _tails]} = zipper),
    do: %Zipper{zipper | path: [l_value | zipper.path], dirs: [:left | zipper.dirs]}

  @doc """
  Get the right child of the focus node, if any.
  """
  @spec right(Zipper.t()) :: Zipper.t() | nil
  def right(%Zipper{path: [%BT{right: nil} | _tail]}), do: nil

  def right(%Zipper{path: [%BT{right: r_value} | _tails]} = zipper),
    do: %Zipper{zipper | path: [r_value | zipper.path], dirs: [:right | zipper.dirs]}

  @doc """
  Get the parent of the focus node, if any.
  """
  @spec up(Zipper.t()) :: Zipper.t() | nil
  def up(%Zipper{dirs: []}), do: nil

  def up(%Zipper{path: [_last_path | pre_path], dirs: [_last_dirs | pre_dirs]} = zipper),
    do: %Zipper{zipper | path: pre_path, dirs: pre_dirs}

  @doc """
  Set the value of the focus node.
  """
  @spec set_value(Zipper.t(), any) :: Zipper.t()
  def set_value(%Zipper{path: [focus | _tail]} = zipper, value),
    do: zipper |> replace_focus(%BT{focus | value: value})

  @doc """
  Replace the left child tree of the focus node.
  """
  @spec set_left(Zipper.t(), BinTree.t() | nil) :: Zipper.t()
  def set_left(%Zipper{path: [focus | _tail]} = zipper, left),
    do: zipper |> replace_focus(%BT{focus | left: left})

  @doc """
  Replace the right child tree of the focus node.
  """
  @spec set_right(Zipper.t(), BinTree.t() | nil) :: Zipper.t()
  def set_right(%Zipper{path: [focus | _tail]} = zipper, right),
    do: zipper |> replace_focus(%BT{focus | right: right})

  defp replace_focus(%Zipper{path: [_focus | rest]} = zipper, new_tree),
    do: %Zipper{zipper | data: update_tree(rest, zipper.dirs, new_tree), path: [new_tree | rest]}

  defp update_tree([], [], new_tree), do: new_tree

  defp update_tree([path_head | path_tails], [:left | dir_tails], new_tree) do
    update_tree(path_tails, dir_tails, %BT{path_head | left: new_tree})
  end

  defp update_tree([path_head | path_tails], [:right | dir_tails], new_tree) do
    update_tree(path_tails, dir_tails, %BT{path_head | right: new_tree})
  end
end
