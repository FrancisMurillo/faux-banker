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
    plug(Guardian.Plug.Pipeline,
      module: FauxBanker.Guardian,
      error_handler: FauxBankerWeb.AuthErrorHandler
    )

    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.EnsureAuthenticated)
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

  scope "/", FauxBankerWeb do
    pipe_through([:browser, :browser_auth])

    get("/", HomeController, :home_screen)

    scope "/clients" do
      get("/:code", ManagerController, :view_screen)
      get("/:code/open_account", ManagerController, :open_account_screen)
      post("/:code/open_account", ManagerController, :open_account)
    end

    scope "/accounts" do
      get("/:code", ClientController, :view_screen)
      get("/:code/withdraw", ClientController, :withdraw_screen)
      post("/:code/withdraw", ClientController, :withdraw)

      get("/:code/deposit", ClientController, :deposit_screen)
      post("/:code/deposit", ClientController, :deposit)
    end

    scope "/requests" do
      get("/", ClientController, :make_request_screen)
      post("/", ClientController, :make_request)

      get("/:code/approve", ClientController, :approve_request_screen)
      post("/:code/approve", ClientController, :approve_request)

      get("/:code/deny", ClientController, :deny_request_screen)
      post("/:code/deny", ClientController, :deny_request)
    end
  end

  scope "/auth", FauxBankerWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    post("/identity/callback", AuthController, :callback)
    get("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :signout)
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.EmailPreviewPlug)
  end
end
