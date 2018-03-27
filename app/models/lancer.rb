class Lancer < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :player
  belongs_to :game, optional: true
  belongs_to :season
  has_many   :pitcher_stats, dependent: :destroy

  def name
    player.name
  end

  def identity
    player.identity
  end

  def throwhand
    player.throwhand
  end

  def opp_team
    if game
      team == game.away_team ? game.home_team : game.away_team
    end
  end

  def opposing_lineup
    if game
      game.batters.where(team: opp_team, starter: true).order("lineup ASC")
    end
  end

  def opposing_batters_handedness
    if game
      opp_lineup = self.opposing_lineup
      opp_lineup = self.predict_opposing_lineup if opp_lineup.size == 0

      throwhand = self.throwhand
      same = opp_lineup.select { |batter| batter.bathand == throwhand }.size
      diff = opp_lineup.size - same

      if throwhand == "L"
        return same, diff
      else
        return diff, same
      end
    end
  end

  def predict_opposing_lineup
    game_day = game.game_day
    i = 1
    while true
      if i == 10
        return Batter.none
      end
      prev_game_day = game_day.previous_days(i)
      unless prev_game_day
        i += 1
        next
      end
      games = prev_game_day.games.includes(:lancers, :batters).where("away_team_id = #{opp_team.id} OR home_team_id = #{opp_team.id}")

      games.each do |game|
        if game.away_team_id == opp_team.id
          opp_pitcher = game.lancers.find_by(starter: true, team_id: game.home_team_id)
        else
          opp_pitcher = game.lancers.find_by(starter: true, team_id: game.away_team_id)
        end

        if opp_pitcher && opp_pitcher.player.throwhand == throwhand
          lineup = game.batters.where(team: opp_team, starter: true).order("lineup ASC")
          next unless lineup.size == 9
          return lineup
        end
      end

      i += 1
    end
  end

  def self.starters
    where(game_id: nil, starter: true)
  end

  def self.bullpen
    where(game_id: nil, bullpen: true)
  end

  def create_game_stats
    lancer = player.create_lancer(self.season)
    lancer.stats.order("id").each do |stat|
      new_stat = stat.dup
      new_stat.lancer_id = self.id
      new_stat.save
    end
  end

  def stats(handedness=nil)
    if pitcher_stats.size == 0
      pitcher_stats.create(lancer_id: self.id, range: "Season", handedness: "L")
      pitcher_stats.create(lancer_id: self.id, range: "Season", handedness: "R")
      pitcher_stats.create(lancer_id: self.id, range: "30 Days", handedness: "")
    end
    unless handedness
      pitcher_stats
    else
      pitcher_stats.find_by(handedness: handedness)
    end
  end

  def view_stats(seasons)
    stat_array = Array.new
    stat_array << self.stats
    seasons.each do |season|
      unless self.season == season
        stat_array << player.create_lancer(season).stats
      end
    end
    return stat_array
  end

  def sort_bullpen
    num_size = [10, 8, 6, 4, 2]
    count = 0
    (1..5).each_with_index do |days, index|
      game_day = self.game.game_day.previous_days(days)
      unless game_day
        next
      end
      game_ids = game_day.games.map { |game| game.id }
      lancer = Lancer.find_by(player: self.player, game_id: game_ids)

      if lancer
        count += lancer.pitches * 10 ** num_size[index]
      end
    end
    return count
  end

  def prev_bullpen_pitches(days)
    unless game
      return nil
    end
    prev_game_day = game.game_day.previous_days(days)
    unless prev_game_day
      return 0
    end
    games = prev_game_day.games
    lancer = Lancer.find_by(player: player, game: games)
    lancer ? lancer.pitches : 0
  end

  def prev_pitchers
    Lancer.includes(game: :game_day)
    .where.not(game: nil)
    .where(player: player, starter: true)
    .where("game_days.date < ?", game.game_day.date)
    .where.not("game_days.date between ? and ?", Date.new(2017, 11, 2), Date.new(2018, 3, 28))
    .order("game_days.date DESC")
    .limit(30)
  end
end
