defmodule Mobilizon.Service.ActivityPub.Converters.Actor do
  @moduledoc """
  Actor converter

  This module allows to convert events from ActivityStream format to our own internal one, and back
  """
  alias Mobilizon.Actors.Actor, as: ActorModel
  alias Mobilizon.Service.ActivityPub.Converter

  @behaviour Converter

  @doc """
  Converts an AP object data to our internal data structure
  """
  @impl Converter
  @spec as_to_model_data(map()) :: map()
  def as_to_model_data(object) do
    %{
      "type" => String.to_existing_atom(object["type"]),
      "preferred_username" => object["preferred_username"],
      "summary" => object["summary"],
      "url" => object["url"],
      "name" => object["name"]
    }
  end

  @doc """
  Convert an actor struct to an ActivityStream representation
  """
  @impl Converter
  @spec model_to_as(ActorModel.t()) :: map()
  def model_to_as(%ActorModel{} = actor) do
    %{
      "type" => Atom.to_string(actor.type),
      "to" => ["https://www.w3.org/ns/activitystreams#Public"],
      "preferred_username" => actor.preferred_username,
      "name" => actor.name,
      "summary" => actor.summary,
      "following" => ActorModel.build_url(actor.preferred_username, :following),
      "followers" => ActorModel.build_url(actor.preferred_username, :followers),
      "inbox" => ActorModel.build_url(actor.preferred_username, :inbox),
      "outbox" => ActorModel.build_url(actor.preferred_username, :outbox),
      "id" => ActorModel.build_url(actor.preferred_username, :page),
      "url" => actor.url
    }
  end
end
