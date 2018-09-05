defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.AccountRequests.Requests.Events.RequestMade do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.AccountRequests.Requests.Events.RequestMade, as: Event

  def decode(%Event{amount: amount} = state),
    do: %Event{state | amount: Decimal.new(amount)}
end
