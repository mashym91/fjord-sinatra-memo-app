require 'sinatra'
require 'sinatra/reloader'

get '/memos' do
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  erb :show
end

post '/memos' do
  erb :index
end

get '/memos/:id/edit' do
  erb :form
end

patch '/memos/:id' do
  erb :index
end

delete '/memos/:id' do
  erb :index
end
