# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'active_support/all'

configure :development, :production do
  set :json_file, 'db/memos.json'
end

configure :test do
  set :json_file, 'db/test_memos.json'
end

JSON_FILE = settings.json_file

enable :method_override

before do
  unless File.exist?(JSON_FILE)
    File.open(JSON_FILE, 'w') do |file|
      hash = { 'memos' => [] }
      JSON.dump(hash, file)
    end
  end

  @memos = []
  File.open(JSON_FILE, 'r') do |file|
    hash = JSON.parse(file.read)
    @memos = hash['memos'] if hash.present?
  end
end

get '/memos' do
  erb :index
end

get '/memos/new' do
  @memo = {}
  erb :form
end

get '/memos/:id' do
  @memo = @memos.find { |m| m['id'] == params[:id].to_i }
  erb :show
end

post '/memos' do
  memo = {}
  memo['id'] = @memos.present? ? @memos.last['id'] + 1 : 1
  memo['title'] = params[:title]
  memo['memo'] = params[:memo]
  memo['created_at'] = Time.now.to_s
  memo['updated_at'] = Time.now.to_s
  memo['deleted_at'] = nil

  new_memos = {}
  new_memos['memos'] = @memos.push(memo)
  File.open(JSON_FILE, 'w') do |file|
    JSON.dump(new_memos, file)
  end

  redirect '/memos'
end

get '/memos/:id/edit' do
  @memo = @memos.find { |m| m['id'] == params[:id].to_i }
  erb :form
end

patch '/memos/:id' do
  memo = @memos.find { |m| m['id'] == params[:id].to_i }
  memo['title'] = params[:title]
  memo['memo'] = params[:memo]
  memo['updated_at'] = Time.now.to_s

  update_memos = {}
  update_memos['memos'] = @memos
  File.open(JSON_FILE, 'w') do |file|
    JSON.dump(update_memos, file)
  end

  redirect '/memos'
end

delete '/memos/:id' do
  memo = @memos.find { |m| m['id'] == params[:id].to_i }
  memo['deleted_at'] = Time.now.to_s

  update_memos = {}
  update_memos['memos'] = @memos
  File.open(JSON_FILE, 'w') do |file|
    JSON.dump(update_memos, file)
  end

  redirect '/memos'
end
