defmodule FauxBanker.Support.Randomizer do
  @moduledoc "Random string generator module.\nThanks https://gist.github.com/ahmadshah/8d978bbc550128cca12dd917a09ddfb7\n"

  @doc "Generate random string based on the given legth. It is also possible to generate certain type of randomise string using the options below:\n* :all - generate alphanumeric random string\n* :alpha - generate nom-numeric random string\n* :numeric - generate numeric random string\n* :upcase - generate upper case non-numeric random string\n* :downcase - generate lower case non-numeric random string\n## Example\n    iex> Iurban.String.randomizer(20) //\"Je5QaLj982f0Meb0ZBSK\"\n"
  def randomizer(length, type \\ :all) do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"

    lists =
      cond do
        type == :alpha ->
          alphabets <> String.downcase(alphabets)

        type == :numeric ->
          numbers

        type == :upcase ->
          alphabets

        type == :downcase ->
          String.downcase(alphabets)

        true ->
          alphabets <> String.downcase(alphabets) <> numbers
      end
      |> String.split("", trim: true)

    do_randomizer(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1 do
    1..length
  end

  defp get_range(_length) do
    [1]
  end

  @doc false
  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn _, acc -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end
end
