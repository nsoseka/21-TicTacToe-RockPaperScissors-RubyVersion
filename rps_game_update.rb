# frozen_string_literal:true
class Participant
  attr_accessor :move, :name
  WIN_CONFIGURATIONS = { 'scissors' => %w(paper lizard),
                         'paper' => %w(rock spock),
                         'rock' => %w(lizard scissors),
                         'lizard' => %w(spock paper),
                         'spock' => %w(scissors rock) }.freeze

  CHOICES = { 'r' => 'rock',
              'p' => 'paper',
              'c' => 'scissors',
              'l' => 'lizard',
              's' => 'spock' }.freeze

  def win?(first, second)
    WIN_CONFIGURATIONS[first].include? second
  end
end

class Player < Participant
  def initialize
    @choice_descriptor = <<-choice
  Choose One
    r for rock
    p for paper
    c for scissors
    s for spock
    l for lizard
  choice
    give_name
  end

  def make_a_play
    play_chosen = ''
    loop do
      puts "=>#{@choice_descriptor}"
      play_chosen = gets.chomp.downcase
      break if CHOICES.keys.include? play_chosen
      puts "=>Enter a valid choice"
    end
    self.move = CHOICES[play_chosen]
  end

  def give_name
    p_name = ''
    loop do
      puts "=>Enter your name"
      p_name = gets.chomp
      break unless p_name.empty? || p_name == " "
      puts "Please enter a valid name"
    end
    self.name = p_name
  end
end

class Computer < Participant
  def initialize
    give_name
  end

  def give_name
    self.name = ['ASUS12', 'Black23', 'YML34if', 'YourPCXX'].sample
  end

  def make_a_play
    case name
    when 'ASUS12'
      self.move = CHOICES.values.take(3).sample
    when 'Black23'
      self.move = CHOICES.values.drop(2).sample
    when 'YML34if'
      self.move = CHOICES.values.take(5).sample
    when 'YourPCXX'
      self.move = CHOICES.values.sample
    end
  end
end

class RPSGame
  attr_accessor :player, :computer

  def initialize
    self.player = Player.new
    self.computer = Computer.new
    set_wincounter_to_zero
  end

  def display_welcome_message
    puts "#{player.name} welcome to the rock paper scissor"
  end

  def display_goodbye_message
    puts "Good bye #{player.name} thanks for playing rock paper scissor"
  end

  def display_winner
    player_move = player.move
    computer_move = computer.move
    if player.win?(player_move, computer_move)
      puts "#{player.name} Won"
    elsif computer.win?(computer_move, player_move)
      puts "#{computer.name} Won"
    else
      puts "Its a tie"
    end
  end

  def win_counter
    if player.win?(player.move, computer.move)
      @win_counter['player_win_counter'] += 1
    elsif computer.win?(computer.move, player.move)
      @win_counter['computer_win_counter'] += 1
    else
      @win_counter['tie_counter'] += 1
    end
  end

  def display_plays
    puts "#{player.name} chose #{player.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_current_results
    print "Scores: #{player.name}[#{@win_counter['player_win_counter']}] "
    print "#{computer.name}[#{@win_counter['computer_win_counter']}] "
    puts "Tie[#{@win_counter['tie_counter']}]"
  end

  def display_final_winner
    winner = @win_counter.select { |k, v| v == 10 && k != 'tie_counter' }
    if winner.keys == ['player_win_counter']
      puts "***#{player.name} Won Game***"
    else
      puts "***#{computer.name} Won Game***"
    end
  end

  def play_again?
    puts "Do you want to play again ('N' to exit 'Any other key' to continue)"
  end

  def set_wincounter_to_zero
    @win_counter = { 'player_win_counter' => 0,
                     'computer_win_counter' => 0,
                     'tie_counter' => 0 }
  end

  def main_gameplay_loop
    loop do
      sleep 3
      system 'cls'
      display_current_results
      player.make_a_play
      computer.make_a_play
      display_plays
      win_counter
      display_winner
      game_win = @win_counter.values.take(2).max
      break if game_win == 10
    end
    display_current_results
    display_final_winner
  end

  def play
    display_welcome_message

    response = ''
    loop do
      main_gameplay_loop
      set_wincounter_to_zero
      play_again?
      response = gets.chomp.downcase
      break if response.start_with?'n'
    end
    display_goodbye_message
  end
end

RPSGame.new.play
