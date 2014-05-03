defmodule DoseFramework.TopPageHandler do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    image = File.read! "priv/cowboy-home.png"
    {:ok, req} = :cowboy_req.reply(200, [], image, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
