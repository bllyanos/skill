defmodule SkillWeb.PageController do
  use SkillWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
