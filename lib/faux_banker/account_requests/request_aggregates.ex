defmodule FauxBanker.AccountRequests.Requests.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests, as: RequestSubContext

  alias Decimal

  alias RequestSubContext.Commands.{MakeRequest}

  alias RequestSubContext.Events.{RequestMade}

  defstruct [
    :id,
    :sender_id,
    :sender_account_id,
    :receipient_id,
    :receipient_account_id,
    :amount,
    :status
  ]

  if Mix.env() != :prod do
    def execute(_state, %State{} = new_state),
      do: new_state

    def apply(_state, %State{} = new_state),
      do: new_state
  end

  def execute(
        _state,
        %MakeRequest{
          id: id,
          sender_id: sender_id,
          sender_account_id: sender_account_id,
          receipient_id: receipient_id,
          code: code,
          amount: amount,
          reason: sender_reason
        }
      ),
      do: %RequestMade{
        id: id,
        sender_id: sender_id,
        sender_account_id: sender_account_id,
        receipient_id: receipient_id,
        code: code,
        amount: amount,
        sender_reason: sender_reason
      }

  def apply(_state, %RequestMade{
        id: id,
        sender_id: sender_id,
        sender_account_id: sender_account_id,
        receipient_id: receipient_id,
        amount: amount
      }),
      do: %State{
        id: id,
        sender_id: sender_id,
        sender_account_id: sender_account_id,
        receipient_id: receipient_id,
        status: :pending,
        amount: amount
      }
end

defmodule FauxBanker.AccountRequests.Requests.Router do
  use Commanded.Commands.Router

  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests, as: RequestSubContext

  alias RequestSubContext.Commands.{MakeRequest}

  alias RequestSubContext.Aggregates, as: State

  identify(State, by: :id, prefix: "request-")

  if Mix.env() != :prod do
    dispatch(State, to: State)
  end

  dispatch(
    [
      MakeRequest
    ],
    to: State
  )
end
