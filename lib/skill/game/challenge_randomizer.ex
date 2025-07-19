defmodule Skill.Game.ChallengeRandomizer do
  alias Skill.Game.Invoker

  @number_of_skills 10

  def randomize(size) when size > 1 do
    for i <- 1..size do
      {i, random_skill()}
    end
  end

  defp random_skill() do
    @number_of_skills
    |> :rand.uniform()
    |> Invoker.invoke()
  end
end
