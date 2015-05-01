require_relative "board.rb"
require_relative "piece.rb"

class Checkers
  def initialize
    @board = Board.new(true)
  end
end

if $PROGRAM_NAME == __FILE__

end