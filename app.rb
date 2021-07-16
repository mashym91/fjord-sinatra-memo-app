# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'active_support/all'

JSON_FILE = 'db/memos.json'

get '/memos' do
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
  erb :index
end

get '/memos/new' do
  erb :form
end

get '/memos/:id' do
  erb :show
end

post '/memos' do
  current_memos = []
  File.open(JSON_FILE) do |file|
    hash = JSON.parse(file.read)
    current_memos = hash['memos']
  end

  memo = {}
  memo['id'] = current_memos.present? ? current_memos.last['id'] + 1 : 1
  memo['title'] = params[:title]
  memo['memo'] = params[:memo]
  memo['created_at'] = Time.now.to_s
  memo['updated_at'] = Time.now.to_s
  memo['deleted_at'] = nil

  dump_memos = {}
  dump_memos['memos'] = current_memos.push(memo)
  File.open(JSON_FILE, 'w') do |file|
    JSON.dump(dump_memos, file)
  end

  @memos = dump_memos['memos']
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
