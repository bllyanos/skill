defmodule Skill.Game.Invoker do
  @doc """
  Sorts the combination
  possible elements are "e" "w" "q"
  Elements can be repeated
  """
  def invoke(combination)

  def invoke({:e, :e, :e}), do: :sun_strike
  def invoke({:q, :e, :e}), do: :forge_spirit
  def invoke({:w, :q, :e}), do: :deafening_blast
  def invoke({:q, :q, :q}), do: :cold_snap
  def invoke({:w, :q, :q}), do: :ghost_walk
  def invoke({:w, :w, :q}), do: :tornado
  def invoke({:w, :w, :w}), do: :emp
  def invoke({:q, :q, :e}), do: :ice_wall
  def invoke({:w, :w, :e}), do: :alacrity
  def invoke({:w, :e, :e}), do: :chaos_meteor

  def invoke(1), do: :cold_snap
  def invoke(2), do: :ghost_walk
  def invoke(3), do: :tornado
  def invoke(4), do: :emp
  def invoke(5), do: :ice_wall
  def invoke(6), do: :deafening_blast
  def invoke(7), do: :alacrity
  def invoke(8), do: :forge_spirit
  def invoke(9), do: :chaos_meteor
  def invoke(10), do: :sun_strike

  def invoke(combination) when is_list(combination) and length(combination) == 3 do
    IO.puts("masuk sini")

    combination
    |> Enum.sort()
    # reverse to make it natural
    |> Enum.reverse()
    |> IO.inspect(label: "before_invoke")
    |> cast()
    |> invoke()
  end

  def invoke(_), do: :error

  defp cast(combination) do
    [a, b, c] =
      for element <- combination do
        cast_element!(element)
      end

    {a, b, c}
  end

  def cast_element!(element) do
    case cast_element(element) do
      {:ok, ele} -> ele
      :error -> raise("Unknown element #{inspect(element)}")
    end
  end

  def info(atom) do
    to_string(atom)
    |> String.split("_")
    |> Enum.map(fn e -> String.capitalize(e) end)
    |> Enum.join(" ")
  end

  def cast_element(element) do
    case element do
      "q" -> {:ok, :q}
      "w" -> {:ok, :w}
      "e" -> {:ok, :e}
      _ -> :error
    end
  end
end
