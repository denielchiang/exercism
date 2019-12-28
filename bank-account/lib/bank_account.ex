defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    Process.flag(:trap_exit, true)
    spawn_link(&receive_msg/0)
  end

  def receive_msg(balance \\ 0) do
    receive do
      {:balance, caller_pid} ->
        send(caller_pid, balance)
        receive_msg(balance)

      {:update, amount} ->
        receive_msg(balance + amount)

      {:close, caller_pid} ->
        exit(:close)
    end
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account) do
    send(account, {:close, self()})
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    send(account, {:balance, self()})

    receive do
      {:EXIT, _pid, :close} ->
        {:error, :account_closed}

      balance ->
        balance
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    send(account, {:update, amount})
  end
end
