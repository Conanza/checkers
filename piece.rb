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

  KING_DIFFS = {
    slides: [[1, -1], [1, 1], [-1, -1], [-1, 1]],
    jumps:  [[2, -2], [2, 2], [-2, -2], [-2, 2]]
  }

  attr_reader :pos, :color, :kinged

  def initialize(board, status)
    @color, @pos = status[:color], status[:pos]
    @board = board
    @kinged = false
    @dir = @color == :black ? 1 : -1
  end

  def display
    { red: "☻".red, black: "☻".black }
  end

  # single moves
  def perform_slide(end_pos)
    begin
      raise InvalidMove unless valid_slide_moves.include?(end_pos)

      @board[pos] = nil
      @pos = end_pos
      @board[end_pos] = self
      @kinged = true if promote?

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
      @pos = end_pos
      @board[end_pos] = self
      @kinged = true if promote?

      true
    rescue InvalidMove => e
      puts e.message
      false
    end
  end

  def promote?
    color == :black && pos[0] == 7 || color == :red && pos[0] == 0
  end

  def valid_slide_moves
    slide_moves.select { |end_pos| valid_pos?(end_pos) }
  end

  def valid_jump_moves
    jump_moves.select { |end_pos| valid_pos?(end_pos) }
  end

  def jump_moves
    row, col = pos

    jumps = if @kinged 
      KING_DIFFS[:jumps].map { |(drow, dcol)| [row + drow, col + dcol] }
    else
      MOVE_DIFFS[:jumps].map { |(drow, dcol)| [row + (drow * @dir), col + dcol] }
    end

    jumps.reject { |jump| @board.empty?(jumped_pos(pos, jump)) }
      .reject { |jump| @board[jumped_pos(pos, jump)].color == color }
  end

  def slide_moves
    row, col = pos

    if @kinged
      KING_DIFFS[:slides].map { |(drow, dcol)| [row + drow, col + dcol] }
    else
      MOVE_DIFFS[:slides].map { |(drow, dcol)| [row + (drow * @dir), col + dcol] }
    end
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) && @board.empty?(pos) }
  end 

  # private?

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


  # p board[test_pos].valid_slide_moves == [[3, 0], [3, 2]]
  # p board[[2, 7]].valid_slide_moves.none? { |mv| mv.nil? }
  # p board[[2, 3]].valid_slide_moves.none? { |mv| mv.nil? }

  # p board[[2, 7]].valid_jump_moves == [[4, 5]]

  # p board[[5, 2]].valid_jump_moves == [[3, 4]]


  # p board[[2, 1]].perform_slide([3, 0])
  # board.render

  # p board[[5, 4]].perform_jump([3, 2])
  # board.render
  # board[[5, 0]].perform_slide([4, 1])
  # board.render
  # p board[[3, 0]].perform_jump([5, 2])
  # p board[[1, 6]].perform_jump([3, 4])

  board[[4, 1]] = nil
  board[[7, 4]] = nil
  board[[6, 3]] = Piece.new(board, color: :black, pos: [6, 3])
  board.render
  p board[[6, 3]].kinged
  p board[[6, 3]].color
  p board[[6, 3]].pos

  board[[6, 3]].perform_slide([7, 4])
  board.render

  p board[[7, 4]].kinged
  p board[[7, 4]].color
  p board[[7, 4]].pos


  board[[7, 4]].perform_slide([6, 3])
  board.render
  p board[[6, 3]].valid_slide_moves
  p board[[6, 3]].valid_jump_moves
end