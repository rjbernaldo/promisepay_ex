defmodule GenerateTokenTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias ExVCR.Config

  setup_all do
    Config.cassette_library_dir(
      "fixture/vcr_cassettes",
      "fixture/custom_cassettes"
    )

    Config.filter_url_params(true)
    Config.filter_request_headers("basic_auth")

    :ok
  end

  setup do
    PromisepayEx.configure(
      username: "test@promisepay.com",
      password: "test",
      environment: "test",
      api_domain: "api.localhost.local:3000",
    )

    Config.filter_request_headers("Authorization")

    :ok
  end

  test "generate_token returns Map" do
    use_cassette "token_auths_request" do
      options = %{
        token_type: "card",
        user_id: "064d6800-fff3-11e5-86aa-5e5517507c66"
      }

      token = PromisepayEx.generate_token(options)

      assert is_map(token)
      assert token.token == "45393cd06fedd253405eccaa4bd8f10d"
      assert token.user_id == "457dd2d8a401fa19693b0c04f0128eb0"
    end
  end

  test "generate_token raises error when unauthorized" do
    use_cassette "unauthorized_token_auths_request" do
      options = %{
        token_type: "card",
        user_id: "064d6800-fff3-11e5-86aa-5e5517507c66"
      }

      try do
        PromisepayEx.generate_token(options)
      rescue
        error in [PromisepayEx.Error] ->
          %{token: ["is not authorized"]} = error.message
      end
    end
  end
end
