require 'sinatra'
require 'sinatra/reloader'
require 'json'

class Memo
  class << self
    def read_json
      File.open("memo.json", "r") do |file|
        @memos = JSON.load(file)
      end
    end

    def write_json
      str = JSON.pretty_generate(@memos)
      File.open("memo.json", "w") do |file|
        file.puts(str)
      end
    end
    
    def titles
      read_json
      memo_titles = {}
      @memos.each do |id, memo|
        memo_titles[id] = memo["title"]
      end
      memo_titles
    end

    def title(id)
      @memos[id]["title"]
    end

    def content(id)
      @memos[id]["content"]
    end

    def add_memo(title, content)
      read_json
      id = Time.new.strftime("%Y-%m-%d %H:%M:%S")
      title = "no_title" if title == ""
      @memos[id]={"title"=>title,"content"=>content}
      write_json
    end

    def delete_memo(id)
      read_json
      @memos.delete(id)
      write_json
    end

    def edit_memo(id, title, content)
      read_json
      @memos[id]["title"] = title
      @memos[id]["content"] = content
      write_json
    end
  end
end

get '/' do
  @title = 'Top'
  @memo_titles = Memo.titles
  erb :top
end

post '/' do
  @title = 'Top'
  Memo.add_memo(params[:title], params[:content])
  @memo_titles = Memo.titles
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
  @memo_id = params[:id]
  @memo_title = Memo.title(@memo_id)
  @memo_content = Memo.content(@memo_id)
  erb :show
end

delete '/show/:id' do
  @memo_id = params[:id]
  Memo.delete_memo(@memo_id)
  erb :delete
end 

get '/edit/:id' do
  @title = 'Edit'
  @memo_id = params[:id]
  @memo_title = Memo.title(@memo_id)
  @memo_content = Memo.content(@memo_id)
  erb :edit
end

get '/new' do
  @title = 'New'
  erb :new
end
