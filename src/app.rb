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

    /(?<team1>[a-zA-Z_]*):\s(?<score1>[0-9])\s\
      (?<team2>[a-zA-Z_]*):\s(?<score2>[0-9])/x =~ line

    if score1.to_i > score2.to_i
      inc_score(win_map, team1, 2)
    elsif score1.to_i < score2.to_i
      inc_score(win_map, team2, 2)
    else
      inc_score(win_map, team1, 1)
      inc_score(win_map, team2, 1)
    end
  end
  win_map
end

def parse_owners
  owners = []

  File.open('../data/owners.txt').each do |line|
    /(?<name>[a-zA-Z]*):\s(?<teams>[a-zA-Z_\s]*)/ =~ line

    o = Owner.new(name, teams.split(' '), 0)
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
