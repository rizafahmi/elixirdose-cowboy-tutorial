defmodule DoseFramework do
  use Application.Behaviour

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
        {:_, [{"/", DoseFramework.TopPageHandler, []}]}
      ])
    {:ok, _} = :cowboy.start_http(:http, 100, [port: 8080], [env: [dispatch: dispatch]])
    IO.inspect "Cowboy run at http://localhost:8080"
    DoseFramework.Supervisor.start_link
  end
end
