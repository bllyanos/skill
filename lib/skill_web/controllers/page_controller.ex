defmodule SkillWeb.PageController do
  use SkillWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def set_name(conn, %{"name" => name}) do
    conn
    |> put_resp_cookie("name", name)
    |> json(%{name: name})
  end
end
