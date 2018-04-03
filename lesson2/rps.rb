class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end

  def >(other_move)
    (rock? && other_move.scissors? || other_move.lizard?) ||
      (paper? && other_move.rock? || other_move.spock?) ||
      (scissors? && other_move.paper? || other_move.lizard?) ||
      (lizard? && other_move.paper? || other_move.spock?) ||
      (spock? && other_move.scissors? || other_move.rock?)
  end

  def <(other_move)
    (rock? && other_move.paper? || other_move.spock?) ||
      (paper? && other_move.scissors? || other_move.lizard?) ||
      (scissors? && other_move.rock? || other_move.spock?) ||
      (lizard? && other_move.rock? || other_move.scissors?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
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
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose Rock, Paper, Scissors, Lizard, or Spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice.downcase)
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

#  Game Orchestration Engine
class RPSGame
  WINNING_SCORE = 3

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Goodbye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "The #{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move # or human.move.>(computer.move)
      puts "#{human.name} won!"
    elsif human.move < computer.move
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
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
  end

  def someone_won?
    human.score >= WINNING_SCORE || computer.score >= WINNING_SCORE
  end

  def winner
    human.name if human.score >= WINNING_SCORE
    computer.name if computer.score >= WINNING_SCORE
  end

  def display_final_score
    display_score
    puts "#{self.winner} won this game!"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def reset_score
    human.score = 0
    computer.score = 0
  end

  def game_round
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      update_score
      display_score
      if someone_won?
        display_final_score
        break
      end
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
