defmodule DoseFramework.TopPageHandler do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    image = File.read! "priv/cowboy-home.png"
    markdown_file = File.read! "priv/docker_tutorial.md"
    markdown_html = Markdown.to_html markdown_file
    {:ok, req} = :cowboy_req.reply(200, [], markdown_html, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
