defmodule FauxBanker.Enums do
  @moduledoc nil

  import EctoEnum

  defenum(Role, admin: 0, manager: 1, client: 2)
  defenum(RequestStatus, pending: 0, approved: 1, rejected: 2)
end
