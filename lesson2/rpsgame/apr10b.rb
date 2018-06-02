class Rock < Move
  def to_s
    'Rock'
  end
end

class Paper < Move
  def to_s
    'Paper'
  end
end

class Scissors < Move
  def to_s
    'Scissors'
  end
end

class Lizard < Move
  def to_s
    'Lizard'
  end
end

class Spock < Move
  def to_s
    'Spock'
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  def initialize
  end

  def >(other_move)
    
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize#(player_type = :human)
    # @player_type = player_type
    @move = nil
    set_name
    @score = 0
  end

  def set_move(choice)
    case choice
    when 'rock'
      self.move = Rock.new
    when 'paper'
      self.move = Paper.new
    when 'scissors'
      self.move = Scissors.new
    when 'lizard'
      self.move = Lizard.new
    when 'spock'
      self.move = Spock.new
    end
  end

  def to_s
    name
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
    set_move(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    choice = Move::VALUES.sample
    set_move(choice)
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

    def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock! Goodbye."
  end

  def display_moves
    puts "#{human.name} chose: #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_result
    if human.move > computer.move
      puts "#{human.name} won this round!"
    elsif computer.move > human.move
      puts "#{computer.name} won this round!"
    else
      puts "It's a tie!"
    end
  end

  def play
    display_welcome_message
    human.choose
    computer.choose
    display_moves
    # display_result
    display_goodbye_message
  end
end

RPSGame.new.play
