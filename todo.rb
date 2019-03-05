$LOAD_PATH.unshift File.dirname(__FILE__)

require "task"
require "list"
require "forecast"

DATABASE_URL = ENV["DATABASE_URL"] || "postgres://localhost/to_do_app"
GITHUB_ACCESS_TOKEN = ENV.fetch("GITHUB_ACCESS_TOKEN")

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, DATABASE_URL)

DataMapper.finalize
Task.auto_upgrade!

class ToDoApp < Sinatra::Base
  use Rack::MethodOverride

  get "/" do
    @tasks = Task.all
    @forecast = Forecast.five_day_forecast("02140")

    erb :index
  end

  post "/" do
    Task.create(params)
    redirect "/"
  end

  get "/:id" do
    @task = Task.get(params[:id])
    erb :show
  end

  put "/:id" do
    task = Task.get(params[:id])
    task.update(
      description: params[:description],
      done: params[:done],
      due_date: params[:due_date]
    )
    redirect "/"
  end

  patch "/:id" do
    task = Task.get(params[:id])
    if task.done?
      task.update(done: false)
    else
      task.update(done: true)
    end
    redirect "/"
  end

  delete "/:id" do
    task = Task.get(params[:id])
    task.destroy
    redirect "/"
  end

  post "/export" do
    list = List.new(Task.all)
    gist = Gist.gist(
      list.to_markdown,
      filename: "To Do List.md",
      access_token: GITHUB_ACCESS_TOKEN
    )
    redirect gist["html_url"]
  end
end
