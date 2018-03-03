module Create
  class Teams

    def self.create
      @teams.each do |team|
        Team.find_or_create_by(team)
      end
    end

    @teams = [
      { name: 'Los Angeles Angels',     abbr: 'laa',      fangraph_id: 1,       zipcode: "92806",   timezone: -3 },
      { name: 'Houston Astros',         abbr: 'hou',      fangraph_id: 21,      zipcode: "77002",   timezone: -1 },
      { name: 'Oakland Athletics',      abbr: 'oak',      fangraph_id: 10,      zipcode: "94621",   timezone: -3 },
      { name: 'Toronto Blue Jays',      abbr: 'tor',      fangraph_id: 14,      zipcode: "M5V 1J1", timezone: 0 },
      { name: 'Atlanta Braves',         abbr: 'atl',      fangraph_id: 16,      zipcode: "30315",   timezone: 0 },
      { name: 'Milwaukee Brewers',      abbr: 'mil',      fangraph_id: 23,      zipcode: "53214",   timezone: -1 },
      { name: 'St. Louis Cardinals',    abbr: 'stl',      fangraph_id: 28,      zipcode: "63102",   timezone: -1 },
      { name: 'Chicago White Sox',      abbr: 'chw',      fangraph_id: 17,      zipcode: "60613",   timezone: -1 },
      { name: 'Arizona Diamondbacks',   abbr: 'ari',      fangraph_id: 15,      zipcode: "85004",   timezone: -3 },
      { name: 'Los Angeles Dodgers',    abbr: 'lad',      fangraph_id: 22,      zipcode: "90012",   timezone: -3 },
      { name: 'San Francisco Giants',   abbr: 'sf',       fangraph_id: 30,      zipcode: "94107",   timezone: -3 },
      { name: 'Cleveland Indians',      abbr: 'cle',      fangraph_id: 5,       zipcode: "44115",   timezone: 0 },
      { name: 'Seattle Mariners',       abbr: 'sea',      fangraph_id: 11,      zipcode: "98134",   timezone: -3 },
      { name: 'Miami Marlins',          abbr: 'mia',      fangraph_id: 20,      zipcode: "33125",   timezone: 0 },
      { name: 'New York Mets',          abbr: 'nym',      fangraph_id: 25,      zipcode: "11368",   timezone: 0 },
      { name: 'Washington Nationals',   abbr: 'wsh',      fangraph_id: 24,      zipcode: "20003",   timezone: 0 },
      { name: 'Baltimore Orioles',      abbr: 'bal',      fangraph_id: 2,       zipcode: "21201",   timezone: 0 },
      { name: 'San Diego Padres',       abbr: 'sd',       fangraph_id: 29,      zipcode: "92101",   timezone: -3 },
      { name: 'Philadelphia Phillies',  abbr: 'phi',      fangraph_id: 26,      zipcode: "19148",   timezone: 0 },
      { name: 'Pittsburgh Pirates',     abbr: 'pit',      fangraph_id: 27,      zipcode: "15212",   timezone: 0 },
      { name: 'Texas Rangers',          abbr: 'tex',      fangraph_id: 13,      zipcode: "76011",   timezone: -1 },
      { name: 'Tampa Bay Rays',         abbr: 'tb',       fangraph_id: 12,      zipcode: "33705",   timezone: 0 },
      { name: 'Boston Red Sox',         abbr: 'bos',      fangraph_id: 3,       zipcode: "02215",   timezone: 0 },
      { name: 'Cincinnati Reds',        abbr: 'cin',      fangraph_id: 18,      zipcode: "45202",   timezone: 0 },
      { name: 'Colorado Rockies',       abbr: 'col',      fangraph_id: 19,      zipcode: "80205",   timezone: -2 },
      { name: 'Kansas City Royals',     abbr: 'kc',       fangraph_id: 7,       zipcode: "64129",   timezone: -1 },
      { name: 'Detroit Tigers',         abbr: 'det',      fangraph_id: 6,       zipcode: "48201",   timezone: 0 },
      { name: 'Minnesota Twins',        abbr: 'min',      fangraph_id: 8,       zipcode: "55403",   timezone: -1 },
      { name: 'Chicago Cubs',           abbr: 'chc',      fangraph_id: 4,       zipcode: "60616",   timezone: -1 },
      { name: 'New York Yankees',       abbr: 'nyy',      fangraph_id: 9,       zipcode: "10451",   timezone: 0 }
    ]
  end
end