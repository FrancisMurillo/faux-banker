defmodule FauxBanker.Generator do
  @moduledoc nil

  import ExMachina
  alias Comeonin.Bcrypt, as: Comeonin
  alias Faker
  alias Timex
  alias UUID

  alias FauxBanker.Randomizer
  alias FauxBanker.Enums.Role

  alias Faker.{
    Cat,
    Commerce,
    Company,
    Phone.EnGb
  }

  def id(),
    do: UUID.uuid4()

  def username(),
    do: sequence("username")

  def password(),
    do: sequence("password")

  def hashed_password(),
    do: "hashed_password" |> sequence() |> Comeonin.hashpwsalt()

  def email(),
    do: sequence(:email, &"email#{&1}@test.com")

  def role(),
    do: sequence(:role, enum_keys(Role))

  def code(),
    do: Randomizer.randomizer(20, :upcase)

  def name(),
    do: Cat.name()

  def phone_number(),
    do: EnGb.number()

  def account_name(),
    do: Company.name()

  def description(), do: Company.catch_phrase()

  def decimal(),
    do: Faker.random_between(1000, 100_000)

  defp enum_keys(enum),
    do: enum.__enum_map__() |> Enum.map(&elem(&1, 0))
end
