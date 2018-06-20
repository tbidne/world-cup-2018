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
    win_map[team_name] += points
  else
    win_map[team_name] = points
  end
end

def parse_scores
  win_map = {}

  File.open('../data/results.txt').each do |line|
    arr = line.scan(/([a-zA-Z_]*):\s([0-9])\s([a-zA-Z_]*):\s([0-9])/)

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
    arr = line.scan(/([a-zA-Z]*):\s([a-zA-Z_\s]*)/)

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

def write_results(owners)
  owners.sort_by! { |o| [o.score, o.score] }.reverse!

  output = "# World Cup 2018\n\n"
  output << "To update, update `data/results.txt` and run `src/app.rb`.\n\n"
  output << "##### Results as of `#{Time.now}`:\n\n"

  output << "| Name | Teams | Score\n| :- | - | -\n"
  owners.each do |o|
    teams = ""
    o.teams.each do |t|
      teams << "![](flags/#{t}.png \"#{t.gsub(/_/, ' ')}\") "
    end
    output << "| #{o.name} | #{teams} | #{o.score} |\n"
  end
  File.open('../README.md', 'w') { |file| file.write(output) }
end

win_map = parse_scores
owners = parse_owners

calc_score(win_map, owners)
write_results(owners)