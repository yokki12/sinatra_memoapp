require 'sinatra'
require 'sinatra/reloader'
require 'json'
use Rack::MethodOverride

class Memo
  class << self
    def read_json
      File.open("memo.json", "r") do |file|
        @memos = JSON.load(file)
      end
    end
    
    def list_titles
      self.read_json
      memo_titles = []
      @memos.each do |id, memo|
        memo_titles <<  "<a href='show/#{id}'>#{memo["title"]}</a>"
      end
      memo_titles
    end

    def show_title(id)
      @memos[id]["title"]
    end

    def show_content(id)
      @memos[id]["content"]
    end

    def add_memo(title, content)
      self.read_json
      addtime = Time.new.strftime("%Y-%m-%d %H:%M:%S")
      title = "no_title" if title == ""
      @memos[addtime]={"title"=>title,"content"=>content}
      str = JSON.pretty_generate(@memos)
      File.open("memo.json", "w") do |file|
        file.puts(str)
      end
    end

    def delete_memo(id)
      self.read_json
      @memos.delete(id)
      str = JSON.pretty_generate(@memos)
      File.open("memo.json", "w") do |file|
        file.puts(str)
      end
    end

    def edit_memo(id, title, content)
      self.read_json
      @memos[id]["title"] = title
      @memos[id]["content"] = content
      str = JSON.pretty_generate(@memos)
      File.open("memo.json", "w") do |file|
        file.puts(str)
      end
    end
  end
end

get '/' do
  @title = 'Top'
  @memo_titles = Memo.list_titles
  erb :top
end

post '/' do
  @title = 'Top'
  Memo.add_memo(params[:title], params[:content])
  @memo_titles = Memo.list_titles
  erb :top
end

patch '/:id' do
  id = params[:id]
  title = params[:title]
  content = params[:content]
  Memo.edit_memo(id, title, content)
  redirect '/'
end

get '/show/:id' do
  @title = 'Show'
  @id = params[:id]
  @memo_title = Memo.show_title("#{@id}")
  @memo_content = Memo.show_content("#{@id}")
  erb :show
end

delete '/show/:id' do
  @id = params[:id]
  Memo.delete_memo(@id)
  erb :delete
end 

get '/edit/:id' do
  @title = 'Edit'
  @id = params[:id]
  @memo_title = Memo.show_title("#{@id}")
  @memo_content = Memo.show_content("#{@id}")
  erb :edit
end

get '/new' do
  @title = 'New'
  erb :new
end
