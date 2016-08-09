# frozen_string_literal: true
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize(human, computer)
    @squares = {}
    reset
    @human = human
    @computer = computer
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers? squares
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts ""
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}   "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}   "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}   "
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def threat?
    threat_or_winner(@human)
  end

  def win_possibility
    threat_or_winner(@computer)
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def threat_or_winner(marker)
    square = ''
    WINNING_LINES.each do |line|
      markers = @squares.values_at(*line)
      if markers.select { |k| k.marked? && k.marker == marker }.size == 2
        empty = @squares.select do |k, v|
          line.include?(k) && v.marker == Square::INITIAL_MARKER
        end
        square = empty.keys
      end
      break if !square.empty?
    end
    square
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

module Player
  attr_reader :marker, :h_name, :c_name

  def initialize
    set_marker
  end
end

class Human
  include Player

  def set_marker
    system 'cls'
    human_marker = ''
    loop do
      puts "Please pick a marker between('X', 'Y', 'T', 'Z', and 'G')"
      human_marker = gets.chomp.upcase
      break if %w(X Y T Z G).include? human_marker.upcase
      puts "Please Choose amongst given set"
    end
    @marker = human_marker
  end

  def set_name
    puts "Enter your name"
    name = ''
    loop do
      name = gets.chomp.capitalize
      break if !name.empty?
      puts "Please enter a valid name"
    end
    @h_name = name
  end
end

class Computer
  include Player

  def set_marker
    @marker = %w(O U P B A C).sample
  end

  def set_name
    @c_name = %w(Blasty ASUS12 CPRENG DLA34).sample
  end
end

class TTTGame
  attr_reader :human, :computer, :board

  def initialize
    @human = Human.new
    @computer = Computer.new
    @curent_marker = human.marker
    @board = Board.new(human.marker, computer.marker)
    reset_win_counter
  end

  def main_game_loop
    loop do
      loop do
        current_player_moves
        switch_player
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end

      winner_counter
      display_result
      break if @win_counter['player'] >= 5 || @win_counter['computer'] >= 5
      reset
    end
  end

  def play
    clear
    set_names
    display_welcome_message
    display_board

    loop do
      main_game_loop
      break unless play_again?
      reset_win_counter
      reset
      display_playagain_message
      display_board
    end
    display_goodbye_message
  end

  private

  def set_names
    human.set_name
    computer.set_name
  end

  def display_welcome_message
    clear
    puts "#{human.h_name} Welcome to Tic Tac Toe"
    puts ""
  end

  def display_goodbye_message
    puts "#{human.h_name} Thanks for playing Tic Tac Toe"
  end

  def display_board
    current_score
    print "#{human.h_name} you are #{human.marker} and "
    puts "#{computer.c_name} is #{computer.marker}"
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_moves
    square = nil
    loop do
      puts "Choose a square between (#{joinor(board.unmarked_keys)})"
      square = gets.chomp.to_i
      break if board.unmarked_keys.include? square
      puts "Sorry its not a valid choice"
    end

    board[square] = human.marker
  end

  def joinor(arr)
    return arr.join(', ').chop.chop + ' or ' + arr.last.to_s if arr.size > 1
    arr[0]
  end

  def added_defense_skills
    sides_left = [1, 3, 7, 9].select { |k| board.unmarked_keys.include?(k) }
    board[sides_left.sample] = computer.marker if !sides_left.empty?
  end

  def attack_first
    if !board.win_possibility.empty?
      board[board.win_possibility.first] = computer.marker
    elsif board.unmarked_keys.include? 5
      board[5] = computer.marker
    end
  end

  def then_defend
    if !board.threat?.empty?
      board[board.threat?.first] = computer.marker
    end
  end

  def choose_random_attack
    if !board.full?
      board[board.unmarked_keys.sample] = computer.marker
    end
  end

  def computer_moves
    if attack_first
    elsif then_defend
    elsif added_defense_skills
    elsif choose_random_attack
    end
  end

  def winner_counter
    case board.winning_marker
    when human.marker
      @win_counter['player'] += 1
    when computer.marker
      @win_counter["computer"] += 1
    else
      @win_counter['ties'] += 1
    end
  end

  def reset_win_counter
    @win_counter = { 'player' => 0,
                     'computer' => 0,
                     'ties' => 0 }
  end

  def current_score
    print "Scores: #{human.h_name}[#{@win_counter['player']}]"
    print " #{computer.c_name}[#{@win_counter['computer']}]"
    puts " Ties[#{@win_counter['ties']}]"
  end

  def display_result
    display_board

    case board.winning_marker
    when human.marker
      puts "#{human.h_name} Won"
    when computer.marker
      puts "#{computer.c_name} Won"
    else
      puts "Its a tie"
    end
  end

  def play_again?
    answer = ''
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry it must be y or n"
    end

    answer == 'y'
  end

  def clear
    system 'cls'
  end

  def reset
    sleep 2
    @board.reset
    @curent_marker = human.marker
    clear
    display_board
  end

  def display_playagain_message
    puts "Lets Play Again"
    puts ""
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
  end

  def switch_player
    @curent_marker = human_turn? ? computer.marker : human.marker
  end

  def human_turn?
    @curent_marker == human.marker
  end
end

game = TTTGame.new
game.play
