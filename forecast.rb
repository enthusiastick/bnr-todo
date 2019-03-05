class Forecast
  CONNECTION = Faraday.new url: "https://api.openweathermap.org" do |connection|
    connection.response :json, content_type: /\bjson$/
    connection.adapter Faraday.default_adapter
  end

  OPEN_WEATHER_API_KEY = ENV["OPEN_WEATHER_API_KEY"]

  class << self
    def five_day_forecast(zipcode)
      url = "/data/2.5/forecast?zip=#{zipcode}&APPID=#{OPEN_WEATHER_API_KEY}"
      consume(CONNECTION.get(url).body)
    end

    def consume(body)
      get_forecast_days(body).reduce({}) do |all, forecast_day|
        all.merge(get_date(forecast_day) => get_icon(forecast_day))
      end
    end

    def get_forecast_days(body)
      body['list']
    end

    def get_date(forecast_day)
      Date.parse(forecast_day["dt_txt"])
    end

    def get_icon(forecast_day)
      icon_code = forecast_day["weather"].first["icon"]
        "https://openweathermap.org/img/w/#{icon_code}.png"
    end
  end
end
