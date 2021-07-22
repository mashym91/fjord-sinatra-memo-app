# frozen_string_literal: true

JSON_FILE = settings.test? ? 'data/test_memos.json' : 'data/memos.json'

class Memo
  def initialize(memo_params)
    @memo = memo_params
  end

  def self.all
    unless File.exist?(JSON_FILE)
      File.open(JSON_FILE, 'w') do |file|
        hash = { 'memos' => [] }
        JSON.dump(hash, file)
      end
    end

    memos = []
    File.open(JSON_FILE, 'r') do |file|
      hash = JSON.parse(file.read)
      memos = hash['memos'] if hash.present?
    end
    memos
  end

  def self.find(id)
    all.find { |m| m['id'] == id.to_i }
  end

  def save
    memos = Memo.all
    @memo['id'] = memos.present? ? memos.last['id'] + 1 : 1
    @memo['created_at'] = Time.now.to_s
    @memo['updated_at'] = Time.now.to_s
    @memo['deleted_at'] = nil

    new_memos = {}
    new_memos['memos'] = memos.push(@memo)
    write_memos(new_memos)
  end

  def update
    memos = Memo.all
    memo = memos.find { |m| m['id'] == @memo[:id] }
    memo['title'] = @memo[:title]
    memo['body'] = @memo[:body]
    memo['updated_at'] = Time.now.to_s

    update_memos = {}
    update_memos['memos'] = memos
    write_memos(update_memos)
  end

  def destroy
    memos = Memo.all
    memo = memos.find { |m| m['id'] == @memo[:id] }

    memo['deleted_at'] = Time.now.to_s

    update_memos = {}
    update_memos['memos'] = memos
    write_memos(update_memos)
  end

  private

  def write_memos(memos)
    File.open(JSON_FILE, 'w') do |file|
      JSON.dump(memos, file)
    end
  end
end
