defmodule FauxBankerWeb.Router do
  use FauxBankerWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :browser_auth do
    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.LoadResource)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FauxBankerWeb do
    pipe_through(:browser)

    get("/registration", AuthController, :register_client_form)
    post("/registration", AuthController, :register_client)

    get("/signin", AuthController, :signin_form)
  end

  scope "/auth", FauxBankerWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    post("/identity/callback", AuthController, :callback)
    get("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", FauxBankerWeb do
  #   pipe_through :api
  # end
end
