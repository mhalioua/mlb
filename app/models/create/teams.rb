module Create
  class Teams

    def self.create
      @teams.each do |team|
        team = Team.find_or_create_by(id: team['id'])
        team.update(name: team['name'], city: team['city'])
      end
    end

    @teams = [
      { id: 1,    name: 'Angels',           city: 'Los Angeles',      espn_abbr: 'LAA',   baseball_abbr: 'LAA',    fangraph_id: 1,       zipcode: "92806",   timezone: -3 },
      { id: 2,    name: 'Astros',           city: 'Houston',          espn_abbr: 'HOU',   baseball_abbr: 'HOU',    fangraph_id: 21,      zipcode: "77002",   timezone: -1 },
      { id: 3,    name: 'Athletics',        city: 'Oakland',          espn_abbr: 'OAK',   baseball_abbr: 'OAK',    fangraph_id: 10,      zipcode: "94621",   timezone: -3 },
      { id: 4,    name: 'Blue Jays',        city: 'Toronto',          espn_abbr: 'TOR',   baseball_abbr: 'TOR',    fangraph_id: 14,      zipcode: "M5V 1J1", timezone: 0 },
      { id: 5,    name: 'Braves',           city: 'Atlanta',          espn_abbr: 'ATL',   baseball_abbr: 'ATL',    fangraph_id: 16,      zipcode: "30315",   timezone: 0 },
      { id: 6,    name: 'Brewers',          city: 'Milwaukee',        espn_abbr: 'MIL',   baseball_abbr: 'MIL',    fangraph_id: 23,      zipcode: "53214",   timezone: -1 },
      { id: 7,    name: 'Cardinals',        city: 'St. Louis',        espn_abbr: 'STL',   baseball_abbr: 'STL',    fangraph_id: 28,      zipcode: "63102",   timezone: -1 },
      { id: 8,    name: 'White Sox',        city: 'Chicago',          espn_abbr: 'CHW',   baseball_abbr: 'CHW',    fangraph_id: 17,      zipcode: "60613",   timezone: -1 },
      { id: 9,    name: 'Diamondbacks',     city: 'Arizona',          espn_abbr: 'ARI',   baseball_abbr: 'ARI',    fangraph_id: 15,      zipcode: "85004",   timezone: -3 },
      { id: 10,   name: 'Dodgers',          city: 'Los Angeles',      espn_abbr: 'LAD',   baseball_abbr: 'LAD',    fangraph_id: 22,      zipcode: "90012",   timezone: -3 },
      { id: 11,   name: 'Giants',           city: 'San Francisco',    espn_abbr: 'SF',    baseball_abbr: 'SFG',    fangraph_id: 30,      zipcode: "94107",   timezone: -3 },
      { id: 12,   name: 'Indians',          city: 'Cleveland',        espn_abbr: 'CLE',   baseball_abbr: 'CLE',    fangraph_id: 5,       zipcode: "44115",   timezone: 0 },
      { id: 13,   name: 'Mariners',         city: 'Seattle',          espn_abbr: 'SEA',   baseball_abbr: 'SEA',    fangraph_id: 11,      zipcode: "98134",   timezone: -3 },
      { id: 14,   name: 'Marlins',          city: 'Miami',            espn_abbr: 'MIA',   baseball_abbr: 'MIA',    fangraph_id: 20,      zipcode: "33125",   timezone: 0 },
      { id: 15,   name: 'Mets',             city: 'New York',         espn_abbr: 'NYM',   baseball_abbr: 'NYM',    fangraph_id: 25,      zipcode: "11368",   timezone: 0 },
      { id: 16,   name: 'Nationals',        city: 'Washington',       espn_abbr: 'WSH',   baseball_abbr: 'WSN',    fangraph_id: 24,      zipcode: "20003",   timezone: 0 },
      { id: 17,   name: 'Orioles',          city: 'Baltimore',        espn_abbr: 'BAL',   baseball_abbr: 'BAL',    fangraph_id: 2,       zipcode: "21201",   timezone: 0 },
      { id: 18,   name: 'Padres',           city: 'San Diego',        espn_abbr: 'SD',    baseball_abbr: 'SDP',    fangraph_id: 29,      zipcode: "92101",   timezone: -3 },
      { id: 19,   name: 'Phillies',         city: 'Philadelphia',     espn_abbr: 'PHI',   baseball_abbr: 'PHI',    fangraph_id: 26,      zipcode: "19148",   timezone: 0 },
      { id: 20,   name: 'Pirates',          city: 'Pittsburgh',       espn_abbr: 'PIT',   baseball_abbr: 'PIT',    fangraph_id: 27,      zipcode: "15212",   timezone: 0 },
      { id: 21,   name: 'Rangers',          city: 'Texas',            espn_abbr: 'TEX',   baseball_abbr: 'TEX',    fangraph_id: 13,      zipcode: "76011",   timezone: -1 },
      { id: 22,   name: 'Rays',             city: 'Tampa Bay',        espn_abbr: 'TB',    baseball_abbr: 'TBD',    fangraph_id: 12,      zipcode: "33705",   timezone: 0 },
      { id: 23,   name: 'Red Sox',          city: 'Boston',           espn_abbr: 'BOS',   baseball_abbr: 'BOS',    fangraph_id: 3,       zipcode: "02215",   timezone: 0 },
      { id: 24,   name: 'Reds',             city: 'Cincinnati',       espn_abbr: 'CIN',   baseball_abbr: 'CIN',    fangraph_id: 18,      zipcode: "45202",   timezone: 0 },
      { id: 25,   name: 'Rockies',          city: 'Colorado',         espn_abbr: 'COL',   baseball_abbr: 'COL',    fangraph_id: 19,      zipcode: "80205",   timezone: -2 },
      { id: 26,   name: 'Royals',           city: 'Kansas City',      espn_abbr: 'KC',    baseball_abbr: 'KCR',    fangraph_id: 7,       zipcode: "64129",   timezone: -1 },
      { id: 27,   name: 'Tigers',           city: 'Detroit',          espn_abbr: 'DET',   baseball_abbr: 'DET',    fangraph_id: 6,       zipcode: "48201",   timezone: 0 },
      { id: 28,   name: 'Twins',            city: 'Minnesota',        espn_abbr: 'MIN',   baseball_abbr: 'MIN',    fangraph_id: 8,       zipcode: "55403",   timezone: -1 },
      { id: 29,   name: 'Cubs',             city: 'Chicago',          espn_abbr: 'CHC',   baseball_abbr: 'CHC',    fangraph_id: 4,       zipcode: "60616",   timezone: -1 },
      { id: 30,   name: 'Yankees',          city: 'New York',         espn_abbr: 'NYY',   baseball_abbr: 'NYY',    fangraph_id: 9,       zipcode: "10451",   timezone: 0 }
    ]
  end
end