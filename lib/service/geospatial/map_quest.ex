defmodule Mobilizon.Service.Geospatial.MapQuest do
  @moduledoc """
  [MapQuest](https://developer.mapquest.com/documentation) backend.

  ## Options
  In addition to the [the shared options](Mobilizon.Service.Geospatial.Provider.html#module-shared-options),
  MapQuest methods support the following options:
  * `:open_data` Whether to use [Open Data or Licenced Data](https://developer.mapquest.com/documentation/open/).
    Defaults to `true`
  """
  alias Mobilizon.Service.Geospatial.Provider
  alias Mobilizon.Addresses.Address
  require Logger

  @behaviour Provider

  @api_key Application.get_env(:mobilizon, __MODULE__) |> get_in([:api_key])

  @api_key_missing_message "API Key required to use MapQuest"

  @impl Provider
  @doc """
  MapQuest implementation for `c:Mobilizon.Service.Geospatial.Provider.geocode/3`.
  """
  @spec geocode(String.t(), keyword()) :: list(Address.t())
  def geocode(lon, lat, options \\ []) do
    api_key = Keyword.get(options, :api_key, @api_key)
    limit = Keyword.get(options, :limit, 10)
    open_data = Keyword.get(options, :open_data, true)

    prefix = if open_data, do: "open", else: "www"

    if is_nil(api_key), do: raise(ArgumentError, message: @api_key_missing_message)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(
             "https://#{prefix}.mapquestapi.com/geocoding/v1/reverse?key=#{api_key}&location=#{
               lat
             },#{lon}&maxResults=#{limit}"
           ),
         {:ok, %{"results" => results, "info" => %{"statuscode" => 0}}} <- Poison.decode(body) do
      results |> Enum.map(&processData/1)
    else
      {:ok, %HTTPoison.Response{status_code: 403, body: err}} ->
        raise(ArgumentError, message: err)
    end
  end

  @impl Provider
  @doc """
  MapQuest implementation for `c:Mobilizon.Service.Geospatial.Provider.search/2`.
  """
  @spec search(String.t(), keyword()) :: list(Address.t())
  def search(q, options \\ []) do
    limit = Keyword.get(options, :limit, 10)
    api_key = Keyword.get(options, :api_key, @api_key)

    open_data = Keyword.get(options, :open_data, true)

    prefix = if open_data, do: "open", else: "www"

    if is_nil(api_key), do: raise(ArgumentError, message: @api_key_missing_message)

    url =
      "https://#{prefix}.mapquestapi.com/geocoding/v1/address?key=#{api_key}&location=#{
        URI.encode(q)
      }&maxResults=#{limit}"

    Logger.debug("Asking MapQuest for addresses with #{url}")

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url),
         {:ok, %{"results" => results, "info" => %{"statuscode" => 0}}} <- Poison.decode(body) do
      results |> Enum.map(&processData/1)
    else
      {:ok, %HTTPoison.Response{status_code: 403, body: err}} ->
        raise(ArgumentError, message: err)
    end
  end

  defp processData(
         %{
           "locations" => addresses,
           "providedLocation" => %{"latLng" => %{"lat" => lat, "lng" => lng}}
         } = _body
       ) do
    case addresses do
      [] -> nil
      addresses -> addresses |> hd |> produceAddress(lat, lng)
    end
  end

  defp processData(%{"locations" => addresses}) do
    case addresses do
      [] -> nil
      addresses -> addresses |> hd |> produceAddress()
    end
  end

  defp produceAddress(%{"latLng" => %{"lat" => lat, "lng" => lng}} = address) do
    produceAddress(address, lat, lng)
  end

  defp produceAddress(address, lat, lng) do
    %Address{
      addressCountry: Map.get(address, "adminArea1"),
      addressLocality: Map.get(address, "adminArea5"),
      addressRegion: Map.get(address, "adminArea3"),
      description: Map.get(address, "street"),
      floor: Map.get(address, "floor"),
      geom: [lng, lat] |> Provider.coordinates(),
      postalCode: Map.get(address, "postalCode"),
      streetAddress: Map.get(address, "street")
    }
  end
end
