defmodule FauxBanker.BankAccounts.Commands do
  defmodule OpenAccount do
    alias __MODULE__, as: Command

    defstruct []
  end
end

defmodule FauxBanker.BankAccounts.Events do
  defmodule AccountOpened do
    defstruct []
  end
end
