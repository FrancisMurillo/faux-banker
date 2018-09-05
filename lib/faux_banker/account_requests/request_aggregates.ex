defmodule FauxBanker.AccountRequests.Requests.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests, as: RequestSubContext

  alias Decimal

  alias RequestSubContext.Commands.{MakeRequest, ApproveRequest}

  alias RequestSubContext.Events.{RequestMade, RequestApproved}

  defstruct [
    :id,
    :sender_id,
    :sender_account_id,
    :receipient_id,
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

  def execute(%State{status: status}, %ApproveRequest{})
      when status != :pending,
      do: {:error, :invalid_status}

  def execute(_state, %ApproveRequest{
        id: id,
        receipient_account_id: receipient_account_id,
        reason: reason
      }),
      do: %RequestApproved{
        id: id,
        receipient_account_id: receipient_account_id,
        receipient_reason: reason
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

  def apply(state, %RequestApproved{}),
    do: %{state | status: :approved}
end

defmodule FauxBanker.AccountRequests.Requests.Router do
  use Commanded.Commands.Router

  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests, as: RequestSubContext

  alias RequestSubContext.Commands.{MakeRequest, ApproveRequest}

  alias RequestSubContext.Aggregates, as: State

  identify(State, by: :id, prefix: "request-")

  if Mix.env() != :prod do
    dispatch(State, to: State)
  end

  dispatch(
    [
      MakeRequest,
      ApproveRequest
    ],
    to: State
  )
end
