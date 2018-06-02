class Rock < Move

end

class Paper < Move

end

class Scissors < Move

end

class Lizard < Move

end

class Spock < Move

end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def rock?
    value == 'rock'
  end

  def paper?
    value == 'paper'
  end

  def scissors?
    value == 'scissors'
  end

  def lizard?
    value == 'lizard'
  end

  def spock?
    value == 'spock'
  end

  def >(other_move)
    rock? && (other_move.scissors? || other_move.lizard?) ||
      paper? && (other_move.rock? || other_move.spock?) ||
      scissors? && (other_move.paper? || other_move.lizard?) ||
      lizard? && (other_move.paper? || other_move.spock?) ||
      spock? && (other_move.scissors? || other_move.rock?)
  end

  # def <(other_move)
  #   rock? && other_move.paper? ||
  #     paper? & other_move.scissors? ||
  #     scissors? && other_move.rock?
  # end

  def to_s
    value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize(player_type = :human)
    @player_type = player_type
    @move = nil
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

# Game Orchestration Engine
class RPSGame
  WINNING_SCORE = 2

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors! Goodbye."
  end

  def display_moves
    puts "#{human.name} chose: #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif computer.move > human.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def update_score
    if human.move > computer.move
      human.score += 1
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def display_score
    puts "#{human.name}: #{human.score}, #{computer.name}: #{computer.score}"
  end

  def someone_won?
    human.score >= WINNING_SCORE || computer.score >= WINNING_SCORE
  end

  def reset_score
    human.score = 0
    computer.score = 0
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n"
    end

    answer.downcase == 'y'
  end

  def game_round
    loop do
      human.choose
      computer.choose
      display_moves
      update_score
      display_winner
      display_score
      break if someone_won?
    end
  end

  def play
    display_welcome_message

    loop do
      game_round
      break unless play_again?
      reset_score
    end

    display_goodbye_message
  end
end

RPSGame.new.play
