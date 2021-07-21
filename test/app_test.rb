# frozen_string_literal: true

require './app'
require 'minitest/autorun'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # 各テストで処理後に削除しているが、エラー時も削除されるようにしたいため
  Minitest.after_run do
    File.delete(JSON_FILE) if File.exist?(JSON_FILE)
  end

  def create_data
    return if File.exist?(JSON_FILE)

    File.open(JSON_FILE, 'w') do |file|
      hash = { "memos": [{ "id": 1, "title": 'テストタイトル', "body": 'テストメモ', "created_at": Time.now, "updated_at": Time.now }] }
      JSON.dump(hash, file)
    end
  end

  def delete_data_file
    File.delete(JSON_FILE) if File.exist?(JSON_FILE)
  end

  def test_expect_get_memos
    get '/memos'
    assert last_response.ok?
    assert_equal '/memos', last_request.path_info
    delete_data_file
  end

  def test_expect_get_new_memos
    get '/memos/new'
    assert last_response.ok?
    assert_equal '/memos/new', last_request.path_info
    delete_data_file
  end

  def test_expect_get_target_memos
    create_data
    get '/memos/1'
    assert last_response.ok?
    assert_equal '/memos/1', last_request.path_info
    delete_data_file
  end

  def test_expect_post_memos
    post '/memos', { title: 'テストタイトル', body: 'テストメモ' }
    assert last_request.post?

    memos = []
    File.open(JSON_FILE, 'r') do |file|
      hash = JSON.parse(file.read)
      memos = hash['memos'] if hash.present?
    end
    assert_equal memos.last['title'], 'テストタイトル'
    assert_equal memos.last['body'], 'テストメモ'
    follow_redirect!  # 明示的にリダイレクト
    assert_equal '/memos', last_request.path_info
    delete_data_file
  end

  def test_expect_get_target_edit_memos
    create_data
    get '/memos/1/edit'
    assert last_response.ok?
    assert_equal '/memos/1/edit', last_request.path_info
    delete_data_file
  end

  def test_expect_patch_memos
    create_data
    patch '/memos/1', { _method: 'PATCH', title: '更新テストタイトル', body: '更新テストメモ' }
    assert last_request.patch?

    memos = []
    File.open(JSON_FILE, 'r') do |file|
      hash = JSON.parse(file.read)
      memos = hash['memos'] if hash.present?
    end

    assert_equal memos.last['title'], '更新テストタイトル'
    assert_equal memos.last['body'], '更新テストメモ'
    follow_redirect!  # 明示的にリダイレクト
    assert_equal '/memos', last_request.path_info
    delete_data_file
  end

  def test_expect_delete_memos
    create_data
    delete '/memos/1', { _method: 'DELETE' }
    assert last_request.delete?

    memos = []
    File.open(JSON_FILE, 'r') do |file|
      hash = JSON.parse(file.read)
      memos = hash['memos'] if hash.present?
    end
    assert memos.last['deleted_at'].nil? == false

    follow_redirect!  # 明示的にリダイレクト
    assert_equal '/memos', last_request.path_info
    delete_data_file
  end
end
