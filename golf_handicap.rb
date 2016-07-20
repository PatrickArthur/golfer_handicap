require 'csv'

# Golfer class, imports csv and runs handicap logic
class Golfer
  def initialize(path)
    csv_text = File.read(path)
    csv = CSV.parse(csv_text, headers: true)
    @handicap = Handicap.new(create_rounds(csv))
  end

  def create_handicap
    @handicap.create_score
  end

  private

  def create_rounds(data)
    rounds = []
    data.each do |row|
      raise 'Missing Row' if row.empty?
      el = row.to_hash
      rounds << Round.new(el['DATE'], el['SCORE'], el['RATING'], el['SLOPE'])
    end
    rounds
  end
end

# Round class, creates a new instance from each row in csv
class Round
  attr_accessor :date, :score, :rating, :slope, :differential

  def initialize(date, score, rating, slope)
    @date = date
    @score = score.to_i
    @rating = rating.to_i
    @slope = slope.to_i
    @differential = ((@score - @rating) * 113) / @slope
  end
end

# Handicap class, creates handicap and performs sort logic
class Handicap
  def initialize(rounds)
    @rounds = sort_data(rounds)
  end

  def create_score
    @rounds.sort! { |a, b| a.differential <=> b.differential }
    scores = @rounds[0..data_map(@rounds.count)].map(&:differential)
    avg_diff = scores.inject { |sum, el| sum + el }.to_f / scores.size
    avg_diff * (96 / 100.to_f)
  end

  private

  def sort_data(data)
    data.sort! { |a, b| b.date <=> a.date }
    check_data(data)
  end

  def check_data(data)
    ct = data.count
    raise "Can't calculate with < 5 rounds" unless ct >= 5
    (ct > 20) ? data[0..19] : data
  end

  def data_map(ct)
    hash = { 5 => 1, 6 => 1, 7 => 2, 8 => 2, 9 => 3,
             10 => 3, 11 => 4, 12 => 4, 13 => 5, 14 => 5, 15 => 6, 16 => 6,
             17 => 7, 18 => 8, 19 => 9, 20 => 10 }
    hash[ct] - 1
  end
end

golfer = Golfer.new('/rounds.csv')
puts "Handicap is #{golfer.create_handicap}"

golfer2 = Golfer.new('/rounds2.csv')
puts "Handicap is #{golfer2.create_handicap}"

golfer3 = Golfer.new('/rounds3.csv')
puts "Handicap is #{golfer3.create_handicap}"

golfer4 = Golfer.new('/rounds4.csv')
puts "Handicap is #{golfer4.create_handicap}"
