require "colorize"
require_relative "piece.rb"

class Board
  attr_reader :board

  def initialize(setup = true)
    @board = Array.new(8) { Array.new(8) }

    make_board(setup)
  end

  def [](pos)
    row, col = pos.first, pos.last
    
    @board[row][col]
  end

  def []=(pos, piece)
    row, col = pos.first, pos.last

    @board[row][col] = piece
  end

  def make_board(setup)
    board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        pos = [i, j]

        if (i + j).odd?
          add_piece(Piece.new(self, color: :black, pos: pos), pos) if i.between?(0, 2)
          add_piece(Piece.new(self, color: :red, pos: pos), pos) if i.between?(5, 7)
        end
      end
    end
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  # def move_piece(start_pos, end_pos, piece)
  #   self[start_pos] = nil
  #   self[end_pos] = piece
  #   self
  # end

  def empty?(pos)
    self[pos].nil?
  end

  def render
    # system "clear"
    print "   "
    8.times { |i| print " #{i} " }
    puts
    board.each_with_index do |row, i|
      print " #{i} "
      row.each_with_index do |piece, j|
        background = (i + j).even? ? :on_yellow : :on_white
        print(piece.nil? ? "   ".send(background) : 
          " #{piece.display[piece.color]} ".send(background))
      end
      puts
    end

    nil
  end
end

if $PROGRAM_NAME == __FILE__
  new_board = Board.new(true)
  p new_board.board.flatten.length
  p new_board.render

end