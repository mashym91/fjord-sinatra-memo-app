# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'active_support/all'

JSON_FILE = settings.test? ? 'db/test_memos.json' : 'db/memos.json'

enable :method_override

helpers do
  alias_method :h, :escape_html
end

error 404 do
  erb :error_not_found
end

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

def write_memos(memos)
  File.open(JSON_FILE, 'w') do |file|
    JSON.dump(memos, file)
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
  memo['title'] = h params[:title]
  memo['memo'] = h params[:memo]
  memo['created_at'] = Time.now.to_s
  memo['updated_at'] = Time.now.to_s
  memo['deleted_at'] = nil

  new_memos = {}
  new_memos['memos'] = @memos.push(memo)
  write_memos(new_memos)

  redirect '/memos'
end

get '/memos/:id/edit' do
  @memo = @memos.find { |m| m['id'] == params[:id].to_i }
  erb :form
end

patch '/memos/:id' do
  memo = @memos.find { |m| m['id'] == params[:id].to_i }
  memo['title'] = h params[:title]
  memo['memo'] = h params[:memo]
  memo['updated_at'] = Time.now.to_s

  update_memos = {}
  update_memos['memos'] = @memos
  write_memos(update_memos)

  redirect '/memos'
end

delete '/memos/:id' do
  memo = @memos.find { |m| m['id'] == params[:id].to_i }
  memo['deleted_at'] = Time.now.to_s

  update_memos = {}
  update_memos['memos'] = @memos
  write_memos(update_memos)

  redirect '/memos'
end
