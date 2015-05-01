require_relative "board.rb"
require_relative "piece.rb"
  
class InvalidInputError < ArgumentError
  def message
    "You can't select that. Try again."
  end
end

class Checkers
  COLUMNS = {
    "a" => 0,
    "b" => 1,
    "c" => 2,
    "d" => 3,
    "e" => 4,
    "f" => 5,
    "g" => 6,
    "h" => 7
  }

  ROWS = {
    "1" => 0,
    "2" => 1,
    "3" => 2,
    "4" => 3,
    "5" => 4,
    "6" => 5,
    "7" => 6,
    "8" => 7
  }

  def initialize
    @board = Board.new(true)
    @current_turn = :black
  end


  def play
    until @board.over?
      system "clear"
      @board.render
      
      puts "#{@current_turn.to_s.capitalize}'s turn."
      start_pos = get_start_pos
      
      begin
        move_seq = get_moves
        @board[start_pos].perform_moves(move_seq)
      rescue InvalidMoveError
        retry
      end

      switch_turns
    end

    switch_turns
    puts "#{@current_turn.to_s.capitalize} wins!"
  end

  def save
    File.open("saved_chess_game.yml", "w") do |f|
      f.puts(self.to_yml)
    end
  end

  private

    def get_moves
      puts "\nSelect move(s) you want to make."
      puts "Separate multiple moves with spaces (e.g. B1 C2 D3)"
  
      user_input = gets.downcase.chomp
      user_input.split.map { |input| parse_input(input) }
    end

    def get_start_pos
      puts "Please select a piece to move (format: A1): "
      
      begin
        user_input = gets.downcase.chomp
        start_pos = parse_input(user_input)

        raise InvalidInputError if start_pos.any? { |xy| xy.nil? }
        raise InvalidInputError if @board.empty?(start_pos)
        raise InvalidInputError if @board[start_pos].color != @current_turn
      rescue InvalidInputError => e
        puts e.message
        retry
      end

      puts "You selected #{user_input}."

      start_pos
    end

    def parse_input(input)
      col, row = input.split("")

      [ROWS[row], COLUMNS[col]]
    end

    def switch_turns
      @current_turn = @current_turn == :black ? :red : :black
    end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.empty?
    new_game = Checkers.new
    new_game.play
  else
    file = ARGV.shift
  end
end