# frozen_string_literal: true
module Cards
  def initialize_deck_of_cards
    @suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
    @faces = ['2', '3', '4', '5', '6', '7', '8', '9',
              '10', 'Jack', 'Queen', 'King', 'Ace']
    @deck_of_cards = []
    @suits.each { |z| @faces.each { |b| @deck_of_cards.push([z, b]) } }
    @deck_of_cards
  end
end

class Dealer
  include Cards
  attr_accessor :player_cards, :dealer_cards, :deck
  attr_reader :cards
  def initialize
    @deck = initialize_deck_of_cards
    @player_cards = @deck.shuffle!.pop(2)
    @dealer_cards = @deck.pop(2)
  end

  def deal_player_card
    @player_cards << deck.pop
  end

  def deal_dealer_card
    @dealer_cards << deck.pop
  end
end

module Calculations
  def sum_of_cards(cards)
    number_of_aces = cards.flatten.count('Ace')
    sum = 0
    cards.each do |card|
      card_value = card[1].to_i
      sum += card_value if card_value > 1
      sum += 10 if card_value == 0 && card[1] != 'Ace'
      sum += 11 if card[1] == 'Ace'
    end
    adjustement_for_aces(sum, number_of_aces)
  end

  def adjustement_for_aces(sum, number_of_aces)
    while number_of_aces > 0 && sum > 21
      sum -= 10
      number_of_aces -= 1
    end
    sum
  end
end

class TwentyOneGame
  include Calculations
  attr_reader :dealer, :d_cards, :p_cards, :player_name, :dealer_name

  def initialize
    reset_cards
  end

  def clear
    system 'cls'
  end

  def display_welcome_message
    clear
    centre_display "Welcome to Twenty One"
  end

  def display_goodbye_message
    centre_display "#{player_name} GoodBye Thanks For Playing Twenty One"
  end

  def centre_display(message)
    puts message.center(70)
  end

  def prompt_centre_display
    print ''.center(28)
  end

  def show_player_cards
    centre_display "#{player_name}'s Hand"
    p_cards.each do |card|
      centre_display "#{card[1]} of #{card[0]}"
    end
    centre_display "#Sum: #{sum_of_cards(p_cards)}"
    puts ''
  end

  def full_dealer_card_deatail
    d_cards.each do |card|
      centre_display "#{card[1]} of #{card[0]}"
    end
    centre_display "#Sum: #{sum_of_cards(d_cards)}"
  end

  def less_dealer_card_details
    centre_display "#{d_cards[1][1]} of #{d_cards[1][0]}"
    centre_display "And Unknown Card(s)"
    centre_display "#Sum: ???"
  end

  def show_dealer_cards(show_details: false)
    centre_display "#{dealer_name}'s Hand"
    if show_details == false
      less_dealer_card_details
    elsif show_details == true
      full_dealer_card_deatail
    end
    puts ''
  end

  def show_cards
    clear
    show_dealer_cards
    show_player_cards
  end

  def show_final_cards
    clear
    show_dealer_cards(show_details: true)
    show_player_cards
  end

  def player_hit_or_stay?
    loop do
      centre_display "#{player_name} would you like to (h)it or (s)tay"
      prompt_centre_display
      @decision = gets.chomp.downcase
      break if %w(h s).include? @decision
      centre_display "Please enter a valid decision"
    end
    @decision
  end

  def hit_player?
    if player_hit_or_stay? == 'h'
      centre_display "#{player_name} hits..."
      sleep 2
      dealer.deal_player_card
    else
      centre_display "#{player_name} stays..." if @decision == 's'
      sleep 2
    end
  end

  def dealer_turn
    if !busted?(p_cards)
      if sum_of_cards(d_cards) < 17
        dealer.deal_dealer_card until sum_of_cards(d_cards) >= 17
      end
    end
  end

  def busted?(cards)
    sum_of_cards(cards) > 21
  end

  def winner_by_busting
    if busted?(p_cards)
      centre_display "**#{player_name} busted! #{dealer_name} Won**"
    elsif busted?(d_cards)
      centre_display "**#{dealer_name} busted! #{player_name} Won**"
    end
  end

  def winner_by_comparism
    if sum_of_cards(d_cards) > sum_of_cards(p_cards)
      centre_display "**#{dealer_name} Won**"
    elsif sum_of_cards(p_cards) > sum_of_cards(d_cards)
      centre_display "**#{player_name} Won**"
    end
  end

  def no_winner
    if sum_of_cards(p_cards) == sum_of_cards(d_cards)
      centre_display "^^^Its a Tie^^^"
    end
  end

  def display_winner
    if winner_by_busting
    elsif winner_by_comparism
    elsif no_winner
    end
  end

  def player_turn
    loop do
      hit_player?
      show_cards
      break if busted?(p_cards) || @decision == 's'
    end
  end

  def play_again?
    answer = ''
    loop do
      centre_display "Would you like to play again (y/n)"
      prompt_centre_display
      answer = gets.chomp.downcase
      break if answer.start_with? 'y', 'n'
    end
    answer
  end

  def reset_cards
    @dealer = Dealer.new
    @d_cards = dealer.dealer_cards
    @p_cards = dealer.player_cards
  end

  def set_players_name
    centre_display "Please Enter Your Name"
    loop do
      prompt_centre_display
      @player_name = gets.chomp.capitalize
      break if !@player_name.empty?
      centre_display "Please enter a valid name"
    end
  end

  def set_dealers_name
    @dealer_name = %w(ASUS17 GRANTX2 TRT1XE YOUNG1).sample
  end

  def play
    display_welcome_message
    set_dealers_name
    set_players_name
    loop do
      show_cards
      player_turn
      dealer_turn
      show_final_cards
      display_winner
      break if play_again? == 'n'
      reset_cards
    end
    display_goodbye_message
  end
end

game = TwentyOneGame.new
game.play
