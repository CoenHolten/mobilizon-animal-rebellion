defmodule Mobilizon.Service.Statistics do
  @moduledoc """
  A module that provides cached statistics
  """

  alias Mobilizon.{Actors, Discussions, Events, Users}

  def get_cached_value(key) do
    case Cachex.fetch(:statistics, key, fn key ->
           case create_cache(key) do
             value when not is_nil(value) -> {:commit, value}
             err -> {:ignore, err}
           end
         end) do
      {status, value} when status in [:ok, :commit] -> value
      _err -> nil
    end
  end

  defp create_cache(:local_users) do
    Users.count_users()
  end

  defp create_cache(:local_events) do
    Events.count_local_events()
  end

  defp create_cache(:local_comments) do
    Discussions.count_local_comments()
  end

  defp create_cache(:local_groups) do
    Actors.count_local_groups()
  end

  defp create_cache(:federation_events) do
    Events.count_events()
  end

  defp create_cache(:federation_comments) do
    Discussions.count_comments()
  end

  defp create_cache(:federation_groups) do
    Actors.count_groups()
  end
end
