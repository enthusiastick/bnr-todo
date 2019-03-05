class List
  TEMPLATE = ERB.new(File.read("views/list.erb"), nil, "-")

  def initialize(tasks)
    @forecast = Forecast.five_day_forecast("02140")
    @tasks = tasks
  end

  def to_markdown
    TEMPLATE.result(binding)
  end
end
