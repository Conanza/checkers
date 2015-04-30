require "colorize"

class InvalidMove < ArgumentError
  def message
    "You can't make that move"
  end
end

class Piece
  MOVE_DIFFS = { 
    slides: [[1, -1], [1, 1]], 
    jumps:  [[2, -2], [2, 2]] 
  }

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
    rescue InvalidMove => e
      puts e.message
      false
    end
  end

  def perform_jump(end_pos)
    begin 
      raise InvalidMove unless valid_jump_moves.include?(end_pos)
      
      pos_between = jumped_pos(pos, end_pos)

      @board[pos] = nil
      @board[pos_between] = nil
      pos = end_pos
      @board[end_pos] = self
    rescue InvalidMove => e
      puts e.message
      false
    end
  end

  # check to see if promote after each move
  # reached the back row?
  def promote?
  end

  def valid_slide_moves
    slide_moves.select { |end_pos| valid_pos?(end_pos) }
  end

  def valid_jump_moves
    jump_moves.select { |end_pos| valid_pos?(end_pos) }
  end

  def jump_moves
    row, col = pos
    all_jumps = MOVE_DIFFS[:jumps].map do |(drow, dcol)|
      [row + (drow * @move_dir), col + dcol]
    end

    all_jumps.reject { |jump| @board.empty?(jumped_pos(pos, jump)) }
      .reject { |jump| @board[jumped_pos(pos, jump)].color == color }
  end

  def slide_moves
    MOVE_DIFFS[:slides].map do |(drow, dcol)|
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
  def jumped_pos(start_pos, end_pos)
    start_row, start_col = start_pos
    drow, dcol = end_pos[0] - start_row, end_pos[1] - start_col
    
    [start_row + drow / 2, start_col + dcol / 2]
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
  p board[[2, 7]].valid_slide_moves.none? { |mv| mv.nil? }
  p board[[2, 3]].valid_slide_moves.none? { |mv| mv.nil? }

  p board[[2, 7]].valid_jump_moves == [[4, 5]]

  p board[[5, 2]].valid_jump_moves == [[3, 4]]


  board[[2, 1]].perform_slide([3, 0])
  board.render
end