#!/usr/bin/env ruby

# Usage:
#   - Export Trello board as JSON
#   - Set REPO, login, and password
#   - Run: bundle install
#   - Run: bundle exec ./trello2github.rb my-trello-board.json

require 'octokit'
require 'recursive-open-struct'
require 'json'

REPO='my/repo'

client = Octokit::Client.new \
  login: 'username',
  password: ''

def labels_names(labels)
  labels.map(&:name).reject{ |name| name.empty? }
end

src = RecursiveOpenStruct.new(JSON.parse( IO.read(ARGV[0]) ), recurse_over_arrays: true)
lists = {}

src.lists.each do |list|
  lists[list.id] = list.name
end

src.cards.each do |card|
  if card.closed
    puts "skipping closed card #{card.name}"
    next
  end
  name = card.name
  desc = card.desc
  labels = labels_names(card.labels)
  list = lists[card.idList]
  opts = {
    labels: labels + [list]
  }
  puts name
  client.create_issue(REPO, name, desc, opts)
end