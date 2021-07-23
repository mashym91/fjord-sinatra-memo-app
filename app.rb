# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative 'memo'

JSON_FILE = settings.test? ? 'data/test_memos.json' : 'data/memos.json'

enable :method_override
enable :sessions

def validate_ok?(params)
  return true if params[:title].nil? == false && params[:title].empty? == false

  flash.now[:error] = 'タイトルを入力してください'
  false
end

helpers do
  alias_method :h, :escape_html
end

error 404 do
  erb :error_not_found
end

get '/memos' do
  @memos = Memo.all
  erb :index
end

get '/memos/new' do
  @memo = {}
  erb :form
end

get '/memos/:id' do
  @memo = Memo.find(params[:id])

  erb @memo ? :show : :error_not_found
end

post '/memos' do
  if validate_ok?(params)
    memo = Memo.new(title: h(params[:title]), body: h(params[:body]))
    memo.save

    flash[:message] = '登録しました'
    redirect '/memos'
  else
    @memo = {}
    @memo['body'] = params[:body]
    erb :form
  end
end

get '/memos/:id/edit' do
  @memo = Memo.find(params[:id])
  erb :form
end

patch '/memos/:id' do
  if validate_ok?(params)
    memo = Memo.new(id: params[:id].to_i, title: h(params[:title]), body: h(params[:body]))
    memo.update

    flash[:message] = '更新しました'
    redirect '/memos'
  else
    @memo = {}
    @memo['id'] = params[:id]
    @memo['body'] = params[:body]
    erb :form
  end
end

delete '/memos/:id' do
  memo = Memo.new(id: params[:id].to_i)
  memo.destroy

  flash[:message] = '削除しました'
  redirect '/memos'
end
