class Card
  attr_reader :face, :suit

  def initialize(face, suit)
    @face = face
    @suit = suit
  end

  def to_s
    "#{face} of #{suit}"
  end
end

class Deck
  FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen',
           'King', 'Ace']
  SUITS = ['Diamonds', 'Clubs', 'Hearts', "Spades"]

  attr_accessor :unused_cards, :used_cards

  def initialize
    @unused_cards = []
    @used_cards = []

    SUITS.each do |suit|
      FACES.each { |face| @unused_cards << Card.new(face, suit) }
    end
    @unused_cards.shuffle!
  end

  def draw_card!
    used_cards << unused_cards.pop
    used_cards.last
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def <<(card)
    cards << card
  end

  def to_s
    joinand(cards.map(&:to_s))
  end

  def show_only_first_card
    cards.first
  end

  def total
    total = 0
    cards.select { |card| card.face != 'Ace' }.each do |non_ace_card|
      total += value(non_ace_card)
    end
    cards.select { |card| card.face == 'Ace' }.each do |_|
      total += ((total + 11) > 21 ? 1 : 11)
    end
    total
  end

  def busted?
    total > TwentyOneGame::TARGET
  end

  def value(non_ace_card)
    if %w[Jack Queen King].include?(non_ace_card.face)
      10
    else
      non_ace_card.face.to_i
    end
  end

  def >(other_hand)
    total > other_hand.total
  end

  def <(other_hand)
    total < other_hand.total
  end

  def ==(other_hand)
    total == other_hand.total
  end

  def reset
    self.cards = []
  end

  def joinand(arr_of_strings)
    case arr_of_strings.size
    when 1
      arr_of_strings.first
    when 2
      arr_of_strings.first + " and " + arr_of_strings.last
    else
      arr_of_strings[0..-2].join(', ') + ", and " + arr_of_strings.last
    end
  end
end

class Participant
  attr_accessor :name, :hand

  def initialize
    @name = nil
    @hand = Hand.new
  end

  def reset_hand
    self.hand = Hand.new
  end
end

class Player < Participant
  def ask_name
    input = nil
    loop do
      puts "\nPlease enter your name:"
      input = gets.chomp.strip
      break unless input.empty?
      puts "Sorry, that is not a valid response."
    end
    self.name = input.capitalize
  end
end

class Dealer < Participant
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end
end

class TwentyOneGame
  WINNING_SCORE = 3
  TARGET = 21
  DEALER_TARGET = 17

  attr_accessor :player, :dealer, :player_score, :dealer_score, :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @player_score = nil
    @dealer_score = nil
    @deck = nil
  end

  def play
    set_up_game
    loop do
      reset_scores
      loop do
        play_one_round
        break if someone_got_winning_score?
      end
      display_game_winner
      break unless play_again?
    end
    display_goodbye_message
  end

  def set_up_game
    clear_screen
    display_welcome_message
    player.ask_name
    dealer.set_name
    puts "\nHi #{player.name}! You will be playing against #{dealer.name}."
    press_enter_to_continue
  end

  def reset_scores
    self.player_score = 0
    self.dealer_score = 0
  end

  def play_one_round
    set_up_round
    loop do
      player_turn
      break if player.hand.busted?
      display_dealer_cards
      dealer_turn
      break
    end
    update_scores
    display_round_result
    press_enter_to_continue
    clear_screen
  end

  def someone_got_winning_score?
    player_score >= WINNING_SCORE || dealer_score >= WINNING_SCORE
  end

  def display_game_winner
    display_score
    if player_score > dealer_score
      puts "\nYou won this game!"
    else
      puts "\nYou lost this game!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "\nDo you want to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)
      puts "\nSorry, not a valid response."
    end
    answer == 'y'
  end

  def set_up_round
    clear_screen
    display_score
    reset_cards
    deal_initial_cards
    display_initial_cards
  end

  def display_score
    puts "First player to score #{WINNING_SCORE} wins!"\
         "\nSCORE: #{player.name} has: #{player_score}, "\
         "#{dealer.name} has: #{dealer_score}"
  end

  def reset_cards
    self.deck = Deck.new
    player.hand.reset
    dealer.hand.reset
  end

  def deal_initial_cards
    2.times do |_|
      deal_card_to_player
      deal_card_to_dealer
    end
  end

  def display_initial_cards
    puts "\nDealer has #{dealer.hand.show_only_first_card} and unknown card."
    puts "You have #{player.hand}."
  end

  def player_turn
    loop do
      display_player_total
      answer = get_answer("Do you want to hit or stay?", ['hit', 'stay'])

      if answer == 'hit'
        hit_me(:player)
        break if player.hand.busted?
      elsif answer == 'stay'
        puts "\nYou chose to stay."
        break
      end
    end
  end

  def dealer_turn
    loop do
      break if dealer.hand.total >= DEALER_TARGET
      hit_me(:dealer)
      display_dealer_total
    end
  end

  def hit_me(participant)
    puts "\nDealing card..."
    sleep(1)
    if participant == :player
      deal_card_to_player
      puts "\nYou drew #{deck.used_cards.last}"
    elsif participant == :dealer
      deal_card_to_dealer
      puts "\nDealer drew #{deck.used_cards.last}"
    end
  end

  def display_dealer_cards
    sleep(1)
    puts "\nDealer has #{dealer.hand}"
    display_dealer_total
  end

  def update_scores
    if dealer_won?
      self.dealer_score += 1
    elsif player_won?
      self.player_score += 1
    end
  end

  def display_round_result
    if player.hand.busted?
      display_player_total
      puts "\nYou busted, you lost."
    elsif dealer.hand.busted?
      puts "\nDealer busted, you won!"
    elsif player_won?
      puts "\nYou won!"
    elsif tied?
      puts "\nYou tied."
    elsif dealer_won?
      puts "\nYou lost."
    end
  end

  def deal_card_to_player
    player.hand << deck.draw_card!
  end

  def deal_card_to_dealer
    dealer.hand << deck.draw_card!
  end

  def display_player_total
    sleep(1)
    puts "\nYour total is: #{player.hand.total}"
  end

  def display_dealer_total
    sleep(1)
    puts "\nDealer's total is #{dealer.hand.total}"
  end

  def get_answer(question, answers_array)
    input = nil

    loop do
      puts "\n#{question}"
      input = gets.chomp.downcase.strip
      if !input.empty? && answers_array.any? { |ansr| ansr.start_with?(input) }
        break
      end
      puts "Sorry, that is not a valid response."
    end

    answers_array.each do |answer|
      input = answer if answer.start_with?(input)
    end

    input
  end

  def tied?
    no_one_busted? && player.hand == dealer.hand
  end

  def player_won?
    dealer.hand.busted? || (no_one_busted? && player.hand > dealer.hand)
  end

  def dealer_won?
    player.hand.busted? || (no_one_busted? && player.hand < dealer.hand)
  end

  def no_one_busted?
    !player.hand.busted? && !dealer.hand.busted?
  end

  def display_welcome_message
    puts "Welcome to #{TARGET}!"
  end

  def press_enter_to_continue
    input = nil
    loop do
      puts "\nPlease press enter to continue."
      input = gets
      break if input
    end
  end

  def clear_screen
    system('clear') || system('clr')
  end

  def display_goodbye_message
    puts "\nThanks for playing #{TARGET}, goodbye!"
  end
end

game = TwentyOneGame.new
game.play
