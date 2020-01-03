defmodule BankAccount do
  use GenServer

  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid
  @init_balance 0

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    {:ok, account} = GenServer.start_link(__MODULE__, @init_balance)
    account
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account), do: GenServer.call(account, :close)

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account), do: GenServer.call(account, :balance)

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount), do: GenServer.call(account, {:update, amount})

  # call back
  def init(init_balance) do
    {:ok, %{balance: init_balance, closed: false}}
  end

  def handle_call(:close, _caller_pid, account), do: {:reply, :ok, %{account | closed: true}}

  def handle_call(:balance, _caller_pid, %{:closed => true} = account),
    do: {:reply, {:error, :account_closed}, account}

  def handle_call(:balance, _caller_pid, account), do: {:reply, account.balance, account}

  def handle_call({:update, _amount}, _caller_pid, %{:closed => true} = account),
    do: {:reply, {:error, :account_closed}, account}

  def handle_call({:update, amount}, _caller_pid, account) do
    new_account =
      account
      |> Map.update!(:balance, &(&1 + amount))

    {:reply, new_account.balance, new_account}
  end
end
