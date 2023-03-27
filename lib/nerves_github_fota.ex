defmodule NervesGithubFOTA do
  @moduledoc """
  """

  @github_api_url "https://api.github.com"

  def update(url) do
    %NervesHubLinkCommon.Message.UpdateInfo{firmware_url: url}
    |> NervesHubLinkCommon.UpdateManager.apply_update
  end

  def update(user, repo, version) do
    response =
      [@github_api_url, "repos", user, repo, "releases"]
      |> Enum.join("/")
      |> HTTPoison.get

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        releases = Jason.decode!(body)

        release =
          releases
          |> Enum.reject(fn release -> release["draft"] == true end)
          |> Enum.find(fn release -> release["name"] == version end)

        case release do
          nil ->
            {:error, :version_not_found}

          _ ->
            url =
              release
              |> Map.get("assets")
              |> Enum.find(fn asset -> String.ends_with?(asset["name"], ".fw") end)
              |> Map.get("browser_download_url")

            IO.puts "Firmware URL: #{url}"

            update(url)
        end

      error ->
        error
    end
  end
end
