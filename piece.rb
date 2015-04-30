require "colorize"

class Piece
  attr_reader :color

  def initialize(color, board)
    @color, @board = color, board
    @kinged = false
    @move_dir = @color == :red ? :north : :south
  end

  def display
    { red: "☻".red, black: "☻".blue }
  end

  # single moves
  # Should return false if illegal; true otherwise
  def perform_slide

  end

  def perform_jump
    # removes piece after jump
  end

  def maybe_promote
    # check to see if promote affter each move
    # reached the back row?
  end


  def valid_pos?(pos)

  end 

  # private?

  # helper method
  # dirs a piece can move in



  def move_diffs
     { slides: [[1, 1], [1, -1]], jumps: [[2, 2], [2, -2]] }
  end
end



if $PROGRAM_NAME == __FILE__

end