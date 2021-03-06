class Move
  VALUES = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock'].freeze

  attr_reader :name, :defeaters
  attr_accessor :action, :result

  def to_s
    name
  end
end

class Rock < Move
  def initialize
    @name = 'Rock'
    @defeaters = ['Paper', 'Spock']
  end

  def >(other_move)
    other_move.is_a?(Scissors) || other_move.is_a?(Lizard)
  end

  def action(other_move)
    if other_move.is_a?(Scissors) || other_move.is_a?(Lizard)
      'crushes'
    elsif other_move.is_a?(Paper)
      'covered by'
    elsif other_move.is_a?(Spock)
      'vaporized by'
    end
  end
end

class Paper < Move
  def initialize
    @name = 'Paper'
    @defeaters = ['Scissors', 'Lizard']
  end

  def >(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Spock)
  end

  def action(other_move)
    if other_move.is_a?(Rock)
      'covers'
    elsif other_move.is_a?(Spock)
      'disproves'
    elsif other_move.is_a?(Scissors)
      'cut by'
    elsif other_move.is_a?(Lizard)
      'eaten by'
    end
  end
end

class Scissors < Move
  def initialize
    @name = 'Scissors'
    @defeaters = ['Rock', 'Spock']
  end

  def >(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Lizard)
  end

  def action(other_move)
    if other_move.is_a?(Paper)
      'cuts'
    elsif other_move.is_a?(Lizard)
      'decapitates'
    elsif other_move.is_a?(Rock)
      'crushed by'
    elsif other_move.is_a?(Spock)
      'smashed by'
    end
  end
end

class Lizard < Move
  def initialize
    @name = 'Lizard'
    @defeaters = ['Scissors', 'Rock']
  end

  def >(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Spock)
  end

  def action(other_move)
    if other_move.is_a?(Paper)
      'eats'
    elsif other_move.is_a?(Spock)
      'poisons'
    elsif other_move.is_a?(Scissors)
      'decapitated by'
    elsif other_move.is_a?(Rock)
      'crushed by'
    end
  end
end

class Spock < Move
  def initialize
    @name = 'Spock'
    @defeaters = ['Paper', 'Lizard']
  end

  def >(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Scissors)
  end

  def action(other_move)
    if other_move.is_a?(Rock)
      'vaporizes'
    elsif other_move.is_a?(Scissors)
      'smashes'
    elsif other_move.is_a?(Paper)
      'disproved by'
    elsif other_move.is_a?(Lizard)
      'poisoned by'
    end
  end
end

class Player
  attr_accessor :name, :move, :moves

  def initialize
    @moves = []
  end

  def select_move(choice)
    case choice
    when 'Rock'
      self.move = Rock.new
    when 'Paper'
      self.move = Paper.new
    when 'Scissors'
      self.move = Scissors.new
    when 'Lizard'
      self.move = Lizard.new
    when 'Spock'
      self.move = Spock.new
    end
  end

  def to_s
    name
  end
end

class Human < Player
  def select_name
    puts ''
    n = ''
    loop do
      puts "What is your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry, must enter a value"
      puts ''
    end
    self.name = n.capitalize
  end

  def valid_input?(choice)
    Move::VALUES.select { |value| value.start_with?(choice) }.length == 1
  end

  def choose
    puts ''
    choice = nil
    loop do
      puts "#{name}, please choose Rock, Paper, Scissors, Lizard, or Spock:"
      choice = gets.chomp.capitalize
      break if valid_input?(choice)
      puts "Sorry, invalid choice."
      puts ''
    end
    choice = Move::VALUES.select { |value| value.start_with?(choice) }.first
    self.move = select_move(choice)
  end
end

class Computer < Player
  EVENLY_WEIGHTED_MOVES = { 'Rock' => 10, 'Paper' => 10, 'Scissors' => 10,
                            'Lizard' => 10, 'Spock' => 10 }

  def select_player
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  # R2D2 always chooses Rock
  def choice_r2d2
    select_move('Rock')
  end

  # Hal tends to choose "scissors", and rarely "rock", but never "paper"
  def choice_hal
    select_move(['Rock', 'Scissors', 'Scissors', 'Scissors'].sample)
  end

  # Chappie chooses randomly
  def choice_chappie
    select_move(convert_to_arr(EVENLY_WEIGHTED_MOVES).sample)
  end

  # Sonny favors past winners; disfavors past losers and ties
  def choice_sonny
    weighted_moves = EVENLY_WEIGHTED_MOVES.dup

    decrease_weight(weighted_moves, tied_moves(moves))
    decrease_weight(weighted_moves, lost_moves(moves))
    increase_weight(weighted_moves, won_moves(moves))

    select_move(convert_to_arr(weighted_moves).sample)
  end

  # Number 5 favors the defeaters of human's won and tied moves
  def choice_number5(human_moves)
    weighted_moves = EVENLY_WEIGHTED_MOVES.dup

    human_won_and_tied = won_moves(human_moves) + tied_moves(human_moves)

    human_won_and_tied.each do |move|
      move.defeaters.each do |defeater|
        weighted_moves[defeater] += 1
      end
    end

    select_move(convert_to_arr(weighted_moves).sample)
  end

  def choose(human_moves)
    case name
    when 'R2D2'
      choice_r2d2
    when 'Hal'
      choice_hal
    when 'Chappie'
      choice_chappie
    when 'Sonny'
      choice_sonny
    when "Number 5"
      choice_number5(human_moves)
    end
  end

  protected

  def convert_to_arr(moves_hash)
    arr = []
    moves_hash.each do |move, weight|
      weight.times { arr << move }
    end
    return convert_to_arr(EVENLY_WEIGHTED_MOVES) if arr.empty?
    arr
  end

  def decrease_weight(moves_hash, selected_moves)
    selected_moves.each do |move|
      moves_hash[move.name.downcase] -= 1
    end
  end

  def increase_weight(moves_hash, selected_moves)
    selected_moves.each do |move|
      moves_hash[move.name.downcase] += 1
    end
  end

  def tied_moves(past_moves)
    past_moves.select { |move| move.result == :tie }
  end

  def lost_moves(past_moves)
    past_moves.select { |move| move.result == :lost }
  end

  def won_moves(past_moves)
    past_moves.select { |move| move.result == :won }
  end
end

class RPSGame
  WINNING_SCORE = 5

  attr_accessor :human, :computer, :human_score, :computer_score

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def round
    display_current_score
    human.choose
    computer.choose(human.moves)
    display_moves
    update_round_results
    update_moves_histories
    update_score
    display_outcome
  end

  def game
    reset_score
    computer.select_player
    display_players_names

    loop do
      round
      break if someone_won?
    end
  end

  def play
    display_welcome_message
    human.select_name
    display_greeting

    loop do
      game
      display_final_score
      display_game_winner
      break unless play_again?
    end

    display_goodbye_message
  end

  protected

  def press_to_continue
    puts "Please press enter to continue:"
    loop do
      input = gets
      break if input
    end
  end

  def display_welcome_message
    system('clear') || system('cls')
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    sleep(1)
  end

  def display_greeting
    puts ''
    puts "Hi #{human.name}, let's play!"
    sleep(1)
  end

  def reset_score
    self.human_score = 0
    self.computer_score = 0
  end

  def display_players_names
    system('clear') || system('cls')
    puts "For this game, #{human.name} will be playing against #{computer.name}"
    sleep(1)
    puts ''
    press_to_continue
  end

  def display_current_score
    system('clear') || system('cls')
    puts "First player to score #{WINNING_SCORE} points, wins!"
    sleep(1)
    puts ''
    puts "The current score:"
    puts "#{human.name}: #{human_score}"
    puts "#{computer.name}: #{computer_score}"
    sleep(1)
  end

  def display_moves
    puts ''
    puts "#{human.name} chose #{human.move}"
    sleep(1)
    puts "#{computer.name} chose #{computer.move}"
    sleep(1)
  end

  def update_players_moves_results(human_result, computer_result)
    human.move.result = human_result
    computer.move.result = computer_result
  end

  def update_round_results
    if human.move.class == computer.move.class
      update_players_moves_results(:tie, :tie)
    elsif human.move > computer.move
      update_players_moves_results(:won, :lost)
    else
      update_players_moves_results(:lost, :won)
    end
  end

  def update_moves_histories
    human.moves << human.move
    computer.moves << computer.move
  end

  def tie_round?
    human.move.result == :tie && computer.move.result == :tie
  end

  def human_won_round?
    human.move.result == :won
  end

  def human_lost_round?
    human.move.result == :lost
  end

  def update_score
    if human_won_round?
      self.human_score += 1
    elsif human_lost_round?
      self.computer_score += 1
    end
  end

  def display_tie
    puts "Both players chose #{human.move}."
    sleep(1)
    puts "It's a tie for this round!"
    sleep(1)
  end

  def display_human_won
    action = human.move.action(computer.move)
    puts "#{human.move} #{action} #{computer.move}."
    sleep(1)
    puts "#{human.name} won this round!"
    sleep(1)
  end

  def display_human_lost
    action = human.move.action(computer.move)
    puts "#{human.move} #{action} #{computer.move}."
    sleep(1)
    puts "#{human.name} lost this round!"
    sleep(1)
  end

  def display_outcome
    puts ''
    if tie_round?
      display_tie
    elsif human_won_round?
      display_human_won
    elsif human_lost_round?
      display_human_lost
    end
    puts ''
    press_to_continue
  end

  def someone_won?
    human_score >= WINNING_SCORE || computer_score >= WINNING_SCORE
  end

  def display_final_score
    system('clear') || system('cls')
    puts "The final score:"
    puts "#{human.name}: #{human_score}"
    puts "#{computer.name}: #{computer_score}"
    sleep(1)
  end

  def display_game_winner
    puts ''
    if human_score >= WINNING_SCORE
      puts "#{human.name} won this game!"
    elsif computer_score >= WINNING_SCORE
      puts "#{human.name} lost this game!"
    end
    sleep(1)
  end

  def play_again?
    puts ''
    answer = nil
    loop do
      puts "Do you want to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
    end

    answer == 'y'
  end

  def display_goodbye_message
    puts ''
    puts "Thanks for playing, #{human.name}. Goodbye!"
  end
end

RPSGame.new.play
