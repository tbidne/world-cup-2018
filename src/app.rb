#!/usr/bin/ruby

class Owner
  attr_accessor :name, :teams, :score
  def initialize(name, teams, score)
    @name = name
    @teams = teams
    @score = score
  end
end

def inc_score(win_map, team_name, points)
  if win_map.key? team_name
    curr_score = win_map[team_name]
    win_map[team_name] = curr_score + points
  else
    win_map[team_name] = points
  end
end

def parse_scores
  win_map = {}

  File.open('../data/wc_data.txt').each do |line|
    arr = line.scan(/([a-z]*):\s([0-9])\s([a-z]*):\s([0-9])/)

    next if arr.empty?

    team_one = arr[0][0]
    score_one = arr[0][1].to_i
    team_two = arr[0][2]
    score_two = arr[0][3].to_i

    if score_one > score_two
      inc_score(win_map, team_one, 2)
      inc_score(win_map, team_two, 0)
    elsif score_one < score_two
      inc_score(win_map, team_two, 2)
      inc_score(win_map, team_one, 0)
    else
      inc_score(win_map, team_one, 1)
      inc_score(win_map, team_two, 1)
    end
  end
  win_map
end

def parse_owners
  owners = []

  File.open('../data/owners.txt').each do |line|
    arr = line.scan(/([a-zA-Z]*):\s([a-z\s]*)/)

    next if arr.empty?

    o = Owner.new(arr[0][0], arr[0][1].split(' '), 0)
    owners << o
  end
  owners
end

def calc_score(win_map, owners)
  owners.each do |o|
    o.teams.each do |t|
      o.score += win_map[t] unless win_map[t].nil?
    end
  end
end

win_map = parse_scores
owners = parse_owners

calc_score(win_map, owners)
puts owners.inspect
