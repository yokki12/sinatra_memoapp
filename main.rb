# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

# Memo data
class Memo
  class << self
    def connectdb(*sql)
      PG.connect(dbname: 'memoapp').exec(*sql)
    end

    def titles
      memo_titles = {}
      result = connectdb('SELECT id, title FROM memos')
      result.each do |record|
        memo_titles[record['id']] = record['title']
      end
      memo_titles
    end

    def title(id)
      connectdb('SELECT title FROM memos WHERE id = $1', [id])[0]['title']
    end

    def content(id)
      connectdb('SELECT content FROM memos WHERE id = $1', [id])[0]['content']
    end

    def add_memo(title, content)
      title = 'no_title' if title == ''
      connectdb('INSERT INTO memos (title, content) VALUES ($1, $2)', [title, content]) # rubocop:disable Layout/LineLength
    end

    def delete_memo(id)
      connectdb('DELETE FROM memos WHERE id = $1', [id])
    end

    def edit_memo(id, title, content)
      connectdb('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id]) # rubocop:disable Layout/LineLength
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
  @memo_title = Memo.title(@memo_id)
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
