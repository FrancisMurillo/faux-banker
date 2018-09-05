defmodule FauxBanker.AccountRequests.Requests.Commands do
  @moduledoc nil

  defmodule MakeRequest do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset
    alias UUID

    alias FauxBanker.Support.Randomizer

    alias FauxBanker.{BankAccounts, Clients}
    alias FauxBanker.BankAccounts.BankAccount
    alias FauxBanker.Clients.Client

    defstruct [
      :id,
      :sender_id,
      :sender_account_id,
      :receipient_id,
      :code,
      :amount,
      :reason,
      :account_code,
      :friend_code
    ]

    use ExConstructor

    @schema %{
      id: :binary_id,
      sender_id: :binary_id,
      sender_account_id: :binary_id,
      receipient_id: :binary_id,
      code: :string,
      amount: :decimal,
      reason: :string
    }

    @form_fields [:account_code, :friend_code, :amount, :reason]

    def changeset(%Command{} = command, %Client{id: sender_id}, attrs) do
      {command, @schema}
      |> cast(attrs, Map.keys(@schema))
      |> validate_required(@form_fields)
      |> validate_number(:amount, greater_than: Decimal.new(0))
      |> force_change(:sender_id, sender_id)
      |> (fn changeset ->
            changeset
            |> get_change(:account_code, "")
            |> BankAccounts.get_account_by_code()
            |> case do
              %BankAccount{id: id} ->
                force_change(changeset, :sender_account_id, id)

              _ ->
                add_error(changeset, :account_code, "Account is invalid")
            end
          end).()
      |> (fn changeset ->
            changeset
            |> get_change(:friend_code, "")
            |> Clients.get_client_by_code()
            |> case do
              %Client{id: id} ->
                force_change(changeset, :receipient_id, id)

              _ ->
                add_error(changeset, :friend_code, "Friend is invalid")
            end
          end).()
      |> (fn changeset ->
            if get_field(changeset, :id) do
              changeset
            else
              force_change(changeset, :id, UUID.uuid4())
            end
          end).()
      |> (fn changeset ->
            if get_field(changeset, :code) do
              changeset
            else
              force_change(changeset, :code, Randomizer.randomizer(10, :upcase))
            end
          end).()
    end
  end
end

defmodule FauxBanker.AccountRequests.Requests.Events do
  @moduledoc nil
  defmodule RequestMade do
    @moduledoc nil
    @derive [Poison.Encoder]
    defstruct [
      :id,
      :sender_id,
      :sender_account_id,
      :receipient_id,
      :code,
      :amount,
      :sender_reason
    ]
  end
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.AccountRequests.Requests.Events.RequestMade do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.AccountRequests.Requests.Events.RequestMade, as: Event

  def decode(%Event{amount: amount} = state),
    do: %Event{state | amount: Decimal.new(amount)}
end
