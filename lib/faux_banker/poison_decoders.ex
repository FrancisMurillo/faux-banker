defimpl Poison.Encoder, for: Decimal do
  def encode(value, options) do
    value |> Decimal.to_float() |> Poison.encode!(options)
  end
end
