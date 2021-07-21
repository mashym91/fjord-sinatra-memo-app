# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'byebug'
require 'active_support/all'
require_relative 'memo'

enable :method_override

def validate_ok?(params)
  return true if params[:title].present?
  @error_message = 'タイトルは必須です'
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
    memo = Memo.new({ title: h(params[:title]), body: h(params[:body]) })
    memo.save

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
    memo = Memo.new({ id: params[:id].to_i, title: h(params[:title]), body: h(params[:body]) })
    memo.update

    redirect '/memos'
  else
    @memo = {}
    @memo['id'] = params[:id]
    @memo['body'] = params[:body]
    erb :form
  end
end

delete '/memos/:id' do
  memo = Memo.new({ id: params[:id].to_i })
  memo.destroy

  redirect '/memos'
end
