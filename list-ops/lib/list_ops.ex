defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  def count(l), do: count(l, 0)
  defp count([], rtn), do: rtn
  defp count([_ | tail], rtn), do: count(tail, rtn + 1)

  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])
  def reverse([], rtn), do: rtn
  def reverse([head | tail], rtn), do: reverse(tail, [head | rtn])

  @spec map(list, (any -> any)) :: list
  def map(l, f), do: map(l, f, [])
  def map([], _f, rtn), do: rtn
  def map([head | tail], f, rtn), do: [f.(head) | map(tail, f, rtn)]

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f), do: filter(l, f, [])
  def filter([], _f, rtn), do: rtn
  def filter([head | tail], f, rtn), do: append(head, filter(tail, f, rtn), f.(head))

  defp append(item, rtn, true), do: [item | rtn]
  defp append(_item, rtn, false), do: rtn

  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  def reduce(l, acc, f), do: do_reduce(l, acc, f)
  defp do_reduce([], acc, _f), do: acc
  defp do_reduce([head | tail], acc, f), do: do_reduce(tail, f.(head, acc), f)

  @spec append(list, list) :: list
  def append(a, b), do: do_append(a, b)
  defp do_append([], rtn), do: rtn
  defp do_append([head | tail], rtn), do: [head | do_append(tail, rtn)]

  @spec concat([[any]]) :: [any]
  def concat(ll), do: concat(ll, [])
  def concat([], rtn), do: rtn
  def concat([head | tail], rtn), do: append(head, concat(tail, rtn))
end
