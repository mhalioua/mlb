module Create
  class Teams

    def self.create
      @teams.each do |team|
        Team.find_or_create_by(team)
      end
    end

    @teams = [
      { name: 'Los Angeles Angels',     espn_abbr: 'LAA',   baseball_abbr: 'LAA',    fangraph_id: 1,       zipcode: "92806",   timezone: -3 },
      { name: 'Houston Astros',         espn_abbr: 'HOU',   baseball_abbr: 'HOU',    fangraph_id: 21,      zipcode: "77002",   timezone: -1 },
      { name: 'Oakland Athletics',      espn_abbr: 'OAK',   baseball_abbr: 'OAK',    fangraph_id: 10,      zipcode: "94621",   timezone: -3 },
      { name: 'Toronto Blue Jays',      espn_abbr: 'TOR',   baseball_abbr: 'TOR',    fangraph_id: 14,      zipcode: "M5V 1J1", timezone: 0 },
      { name: 'Atlanta Braves',         espn_abbr: 'ATL',   baseball_abbr: 'ATL',    fangraph_id: 16,      zipcode: "30315",   timezone: 0 },
      { name: 'Milwaukee Brewers',      espn_abbr: 'MIL',   baseball_abbr: 'MIL',    fangraph_id: 23,      zipcode: "53214",   timezone: -1 },
      { name: 'St. Louis Cardinals',    espn_abbr: 'STL',   baseball_abbr: 'STL',    fangraph_id: 28,      zipcode: "63102",   timezone: -1 },
      { name: 'Chicago White Sox',      espn_abbr: 'CHW',   baseball_abbr: 'CHW',    fangraph_id: 17,      zipcode: "60613",   timezone: -1 },
      { name: 'Arizona Diamondbacks',   espn_abbr: 'ARI',   baseball_abbr: 'ARI',    fangraph_id: 15,      zipcode: "85004",   timezone: -3 },
      { name: 'Los Angeles Dodgers',    espn_abbr: 'LAD',   baseball_abbr: 'LAD',    fangraph_id: 22,      zipcode: "90012",   timezone: -3 },
      { name: 'San Francisco Giants',   espn_abbr: 'SF',    baseball_abbr: 'SFG',    fangraph_id: 30,      zipcode: "94107",   timezone: -3 },
      { name: 'Cleveland Indians',      espn_abbr: 'CLE',   baseball_abbr: 'CLE',    fangraph_id: 5,       zipcode: "44115",   timezone: 0 },
      { name: 'Seattle Mariners',       espn_abbr: 'SEA',   baseball_abbr: 'SEA',    fangraph_id: 11,      zipcode: "98134",   timezone: -3 },
      { name: 'Miami Marlins',          espn_abbr: 'MIA',   baseball_abbr: 'MIA',    fangraph_id: 20,      zipcode: "33125",   timezone: 0 },
      { name: 'New York Mets',          espn_abbr: 'NYM',   baseball_abbr: 'NYM',    fangraph_id: 25,      zipcode: "11368",   timezone: 0 },
      { name: 'Washington Nationals',   espn_abbr: 'WSH',   baseball_abbr: 'WSN',    fangraph_id: 24,      zipcode: "20003",   timezone: 0 },
      { name: 'Baltimore Orioles',      espn_abbr: 'BAL',   baseball_abbr: 'BAL',    fangraph_id: 2,       zipcode: "21201",   timezone: 0 },
      { name: 'San Diego Padres',       espn_abbr: 'SD',    baseball_abbr: 'SDP',    fangraph_id: 29,      zipcode: "92101",   timezone: -3 },
      { name: 'Philadelphia Phillies',  espn_abbr: 'PHI',   baseball_abbr: 'PHI',    fangraph_id: 26,      zipcode: "19148",   timezone: 0 },
      { name: 'Pittsburgh Pirates',     espn_abbr: 'PIT',   baseball_abbr: 'PIT',    fangraph_id: 27,      zipcode: "15212",   timezone: 0 },
      { name: 'Texas Rangers',          espn_abbr: 'TEX',   baseball_abbr: 'TEX',    fangraph_id: 13,      zipcode: "76011",   timezone: -1 },
      { name: 'Tampa Bay Rays',         espn_abbr: 'TB',    baseball_abbr: 'TBD',    fangraph_id: 12,      zipcode: "33705",   timezone: 0 },
      { name: 'Boston Red Sox',         espn_abbr: 'BOS',   baseball_abbr: 'BOS',    fangraph_id: 3,       zipcode: "02215",   timezone: 0 },
      { name: 'Cincinnati Reds',        espn_abbr: 'CIN',   baseball_abbr: 'CIN',    fangraph_id: 18,      zipcode: "45202",   timezone: 0 },
      { name: 'Colorado Rockies',       espn_abbr: 'COL',   baseball_abbr: 'COL',    fangraph_id: 19,      zipcode: "80205",   timezone: -2 },
      { name: 'Kansas City Royals',     espn_abbr: 'KC',    baseball_abbr: 'KCR',    fangraph_id: 7,       zipcode: "64129",   timezone: -1 },
      { name: 'Detroit Tigers',         espn_abbr: 'DET',   baseball_abbr: 'DET',    fangraph_id: 6,       zipcode: "48201",   timezone: 0 },
      { name: 'Minnesota Twins',        espn_abbr: 'MIN',   baseball_abbr: 'MIN',    fangraph_id: 8,       zipcode: "55403",   timezone: -1 },
      { name: 'Chicago Cubs',           espn_abbr: 'CHC',   baseball_abbr: 'CHC',    fangraph_id: 4,       zipcode: "60616",   timezone: -1 },
      { name: 'New York Yankees',       espn_abbr: 'NYY',   baseball_abbr: 'NYY',    fangraph_id: 9,       zipcode: "10451",   timezone: 0 }
    ]
  end
end