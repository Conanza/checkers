require "colorize"

class InvalidPosition < ArgumentError
  def message
    "You can't make that move"
  end
end

class Piece
  attr_accessor :pos
  attr_reader :color

  def initialize(board, status)
    @color, @pos = status[:color], status[:pos]
    @board = board
    @kinged = false
    @move_dir = @color == :black ? 1 : -1
  end

  def display
    { red: "☻".red, black: "☻".black }
  end

  # single moves
  def perform_slide(end_pos)
    begin
      raise InvalidMove unless valid_slide_moves.include?(end_pos)

      @board[pos] = nil
      pos = end_pos
      @board[end_pos] = self

      true
    rescue InvalidPosition => e
      puts e.message
      false
    end
  end

  # removes piece after jump
  def perform_jump(end_pos)
    begin 
      raise InvalidMove
    rescue

    end
  end

  # check to see if promote after each move
  # reached the back row?
  def promote?
  end

  def valid_slide_moves
    slide_moves.compact.select { |end_pos| valid_pos?(end_pos) }
  end

  def valid_jump_moves
    jump_moves.compact.select { |end_pos| valid_pos?(end_pos) }
  end

  def jump_moves
    row, col = pos
    moves = move_diffs[:jumps].map do |(drow, dcol)|
      pos_between = [row + (drow / 2 * @move_dir), col + (dcol / 2)]
      next unless pos_between.all? { |coord| coord.between?(0, 7) }
      next if @board.empty?(pos_between)
      next if @board[pos_between].color == color 
      
      [row + (drow * @move_dir), col + dcol]
    end
  end

  def slide_moves
    move_diffs[:slides].map do |(drow, dcol)|
      row, col = pos

      [row + (drow * @move_dir), col + dcol]
    end
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) && @board.empty?(pos) }
  end 

  # private?

  # def move_dirs
  #   { south: 1, north: -1 }
  # end

  def move_diffs
    { 
      slides: [[1, -1], [1, 1]], 
      jumps:  [[2, -2], [2, 2]] 
    }
  end
end



if $PROGRAM_NAME == __FILE__
  require_relative "board.rb"
  board = Board.new(true)

  test_pos = [2, 1]
  # p board[test_pos].jump_moves
  # p board[test_pos].slide_moves

  board[[4, 3]] = Piece.new(board, color: :black, pos: [4, 3])
  board[[3, 6]] = Piece.new(board, color: :red, pos: [3, 6])
  board.render


  p board[test_pos].valid_slide_moves == [[3, 0], [3, 2]]
  p board[[2, 7]].valid_slide_moves
  p board[[2, 3]].valid_slide_moves

  p board[[5, 2]].jump_moves.include?([3, 4]) == true
  p board[[2, 7]].jump_moves.include?([4, 5]) == true

  p board[[5, 2]].valid_jump_moves


  board[[2, 1]].perform_slide([3, 0])
  board.render
end