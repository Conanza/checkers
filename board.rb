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

        if pos.inject(:+).odd?
          add_piece(Piece.new(:black, self), pos) if i.between?(0, 2)
          add_piece(Piece.new(:red, self), pos) if i.between?(5, 7)
        end
      end
    end
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  def render
    board.each do |row|
      row.each do |piece|
        print(piece.nil? ? "_" : "#{piece.display[piece.color]}")
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