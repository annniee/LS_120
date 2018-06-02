class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],     # rows
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],     # columns
                   [1, 5, 9], [3, 5, 7]]                # diagonals

  attr_accessor :squares

  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def [](position)
    squares[position]
  end

  def []=(position, player_marker)
    squares[position].marker = player_marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      line_squares = squares.values_at(*line)
      return line_squares.first.marker if identical?(line_squares)
    end
    nil
  end

  def reset
    (1..9).each { |key| squares[key] = Square.new }
  end

  # rubocop: disable Metrics/AbcSize
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop: enable Metrics/AbcSize

  def at_risk_squares(marker)
    at_risk_squares = []
    WINNING_LINES.each do |line|
      line_squares = @squares.values_at(*line)
      if unmarked_squares(line_squares).size == 1 &&
         marked_squares(line_squares, marker).size == 2
        at_risk_squares << line.select { |num| squares[num].unmarked? }
      end
    end
    at_risk_squares.flatten
  end

  private

  def identical?(array_of_squares)
    return false if array_of_squares.any?(&:unmarked?)
    array_of_squares.map(&:marker).uniq.size == 1
  end

  def unmarked_squares(array_of_squares)
    array_of_squares.select(&:unmarked?)
  end

  def marked_squares(array_of_squares, marker)
    array_of_squares.select { |sq| sq.marker == marker }
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :name, :marker

  def initialize
    @name = nil
    @marker = nil
  end
end

class TTTGame
  FIRST_TO_MOVE = 'choose'
  WINNING_SCORE = 3

  attr_reader :board, :human, :computer
  attr_accessor :current_marker, :human_score, :computer_score,
                :first_player_this_game

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Player.new
    @current_marker = nil
    @human_score = 0
    @computer_score = 0
  end

  def play
    clear_screen
    display_welcome_message
    set_up_players_names_and_markers
    display_computer_player_name

    loop do
      self.first_player_this_game = who_is_first(FIRST_TO_MOVE)
      self.current_marker = first_player_this_game

      game

      display_game_result
      break unless play_again?
      reset_board_and_score
    end

    display_goodbye_message
  end

  private

  def clear_screen
    system('clear') || system('cls')
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
  end

  def set_up_players_names_and_markers
    ask_human_name
    ask_human_marker
    pick_computer_name
    pick_computer_marker
  end

  def display_computer_player_name
    puts "For this game you will be playing against #{computer.name}."
  end

  def ask_human_name
    puts "\nPlease enter your name:"
    input_name = nil
    loop do
      input_name = gets.chomp.strip.capitalize
      break unless input_name.empty?
      puts "\nSorry, that is not a valid response."
    end

    human.name = input_name
  end

  def ask_human_marker
    puts "\nHi, #{human.name}! Please choose a single character as your game "\
         "marker (e.g. X, O, etc):"
    input_marker = nil
    loop do
      input_marker = gets.chomp.strip.upcase
      break if input_marker.size == 1
      puts "\nSorry, that is not a valid response."
    end

    human.marker = input_marker
    puts ''
  end

  def pick_computer_name
    computer.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def pick_computer_marker
    computer.marker = ['X', 'O'].reject { |char| char == human.marker }.sample
  end

  def who_is_first(first)
    case first
    when 'human'
      human.marker
    when 'computer'
      computer.marker
    when 'choose'
      yes?("\nDo you want to go first? (y/n)") ? human.marker : computer.marker
    end
  end

  def game
    loop do
      display_score
      display_board

      game_round

      update_score if board.someone_won?
      display_round_result
      break if someone_got_winning_score?
      press_enter_to_continue
      reset_board
    end
  end

  def display_score
    clear_screen
    puts "First player to score #{WINNING_SCORE} wins."
    puts "\nCurrent score: "\
         "#{human.name}: #{human_score}, #{computer.name}: #{computer_score}"
  end

  def display_board
    puts "\n#{human.name} is #{human.marker} and "\
         "#{computer.name} is #{computer.marker}"
    puts "\n"
    board.draw
  end

  def game_round
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      if current_marker == human.marker
        clear_screen
        display_score
        display_board
      end
    end
  end

  def yes?(question)
    answer = nil
    loop do
      puts question
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)
      puts "\nSorry, not a valid response."
    end

    answer == 'y'
  end

  def human_moves
    puts "\nChoose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "\nSorry, that is not a valid choice."
    end

    board[square] = human.marker
  end

  def offense_squares(player_marker)
    board.at_risk_squares(player_marker)
  end

  def mark_offense_square(player_marker)
    board[offense_squares(player_marker).sample] = player_marker
  end

  def defence_squares(opponent_marker)
    board.at_risk_squares(opponent_marker)
  end

  def mark_defence_square(opponent_marker, player_marker)
    board[defence_squares(opponent_marker).sample] = player_marker
  end

  def middle_square_available?
    board[5].unmarked?
  end

  def mark_middle_square(player_marker)
    board[5] = player_marker
  end

  def mark_random_square(player_marker)
    board[board.unmarked_keys.sample] = player_marker
  end

  def computer_moves
    marker = computer.marker
    if !offense_squares(marker).empty?
      mark_offense_square(marker)
    elsif !defence_squares(human.marker).empty?
      mark_defence_square(human.marker, marker)
    elsif middle_square_available?
      mark_middle_square(marker)
    else
      mark_random_square(marker)
    end
  end

  def current_player_moves
    if current_marker == human.marker
      human_moves
      self.current_marker = computer.marker
    elsif current_marker == computer.marker
      computer_moves
      self.current_marker = human.marker
    end
  end

  def update_score
    if board.winning_marker == human.marker
      self.human_score += 1
    elsif board.winning_marker == computer.marker
      self.computer_score += 1
    end
  end

  def joinor(array_of_strings)
    case array_of_strings.size
    when 1
      array_of_strings.first
    when 2
      array_of_strings.join(' and ')
    else
      array_of_strings[0..-2].join(', ') + ' and ' + array_of_strings.last.to_s
    end
  end

  def display_round_result
    clear_screen
    display_score
    display_board

    case board.winning_marker
    when human.marker
      puts "\n#{human.name} won this round!"
    when computer.marker
      puts "\n#{computer.name} won this round!"
    else
      puts "\nIt's a tie!"
    end
  end

  def someone_got_winning_score?
    human_score == WINNING_SCORE || computer_score == WINNING_SCORE
  end

  def press_enter_to_continue
    puts "\nPress enter to continue..."
    loop do
      input = gets
      break if input
    end
  end

  def reset_board
    board.reset
    self.current_marker = first_player_this_game
    clear_screen
  end

  def display_game_result
    puts "\n#{human.name} won the game!" if human_score == WINNING_SCORE
    puts "\n#{computer.name} won the game!" if computer_score == WINNING_SCORE
  end

  def reset_board_and_score
    reset_board
    self.human_score = 0
    self.computer_score = 0
  end

  def play_again?
    yes?("\nDo you want to play again? (y/n)")
  end

  def display_goodbye_message
    puts "\nThanks for playing Tic Tac Toe! Goodbye, #{human.name}!"
  end
end

game = TTTGame.new
game.play
