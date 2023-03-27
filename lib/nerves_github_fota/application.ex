defmodule NervesGithubFOTA.Application do
  use Application

  alias NervesHubLinkCommon.FwupConfig
  alias NervesHubLinkCommon.UpdateManager

  require Logger

  def start(_type, _args) do
    fwup_config = %FwupConfig{
      handle_fwup_message: &handle_fwup_message/1,
      update_available: fn _ -> :apply end
    }

    children = [
      {UpdateManager, fwup_config},
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: NervesGithubFOTA.Supervisor
    )
  end

  @doc false
  defp handle_fwup_message({:progress, percent}),
    do: Logger.debug("[NervesGithubFOTA] firmware updating: #{percent}%")

  defp handle_fwup_message({:warning, _, message}),
    do: Logger.warn("[NervesGithubFOTA] #{message}")

  defp handle_fwup_message({:error, _, message}),
    do: Logger.error("[NervesGithubFOTA] #{message}")

  defp handle_fwup_message({:ok, 0, _message}) do
    Logger.warn("[NervesGithubFOTA] rebooting to apply update")
    Nerves.Runtime.reboot
  end
end
