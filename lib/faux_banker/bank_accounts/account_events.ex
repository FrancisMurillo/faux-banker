defmodule FauxBanker.BankAccounts.Accounts.Commands do
  @moduledoc nil

  defmodule OpenAccount do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset
    alias UUID

    alias FauxBanker.Clients.Client

    defstruct [:id, :client_id, :name, :description, :initial_balance]

    use ExConstructor

    @schema %{
      name: :string,
      description: :string,
      initial_balance: :decimal
    }

    @required_fields [:name, :initial_balance]

    def changeset(%Command{} = command, %Client{id: client_id}, attrs) do
      {command, @schema}
      |> cast(attrs, Map.keys(@schema))
      |> validate_required(@required_fields)
      |> validate_number(:initial_balance, greater_than: Decimal.new(0))
      |> force_change(:client_id, client_id)
      |> prepare_changes(fn changeset ->
        if get_field(changeset, :id) do
          changeset
        else
          force_change(changeset, :id, UUID.uuid4())
        end
      end)
    end
  end
end

defmodule FauxBanker.BankAccounts.Accounts.Events do
  @moduledoc nil
  defmodule AccountOpened do
    @moduledoc nil

    defstruct []
  end
end
