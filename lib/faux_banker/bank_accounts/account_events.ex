defmodule FauxBanker.BankAccounts.Accounts.Commands do
  @moduledoc nil

  defmodule OpenAccount do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset
    alias UUID

    alias FauxBanker.Support.Randomizer

    alias FauxBanker.Clients.Client

    defstruct [:id, :client_id, :code, :name, :description, :initial_balance]

    use ExConstructor

    @schema %{
      id: :binary_id,
      client_id: :binary_id,
      code: :string,
      name: :string,
      description: :string,
      initial_balance: :decimal
    }

    @form_fields [:name, :description, :initial_balance]

    @required_fields [:name, :initial_balance]

    def changeset(%Command{} = command, %Client{id: client_id}, attrs) do
      {command, @schema}
      |> cast(attrs, @form_fields)
      |> validate_required(@required_fields)
      |> validate_number(:initial_balance, greater_than: Decimal.new(0))
      |> force_change(:client_id, client_id)
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
              force_change(changeset, :code, Randomizer.randomizer(6, :upcase))
            end
          end).()
    end
  end
end

defmodule FauxBanker.BankAccounts.Accounts.Events do
  @moduledoc nil
  defmodule AccountOpened do
    @moduledoc nil

    defstruct [:id, :client_id, :code, :name, :description, :balance]
  end
end
