class BatterStat < ApplicationRecord
  belongs_to :batter

  def tld
    unless ld
      0
    else
      tld = ((ld/100 * ab + bb) / (bb + ab) * 100).round(1)
      tld.nan? ? 0 : tld
    end
  end
end
