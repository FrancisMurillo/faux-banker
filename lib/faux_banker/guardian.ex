defmodule FauxBanker.Guardian do
  use Guardian, otp_app: :faux_banker

  def subject_for_token(resource, _claims) do
    resource |> IO.inspect(label: "resource")
    resource |> IO.inspect(label: "claims")
    sub = to_string("ASdasd")
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, nil}
  end
end
