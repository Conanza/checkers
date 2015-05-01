require "colorize"
require_relative "piece.rb"

class Board
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
    return self if setup == false

    @board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        pos = [i, j]

        if (i + j).odd?
          self[pos] = Piece.new(self, color: :black, pos: pos)if i.between?(0, 2)
          self[pos] = Piece.new(self, color: :red, pos: pos) if i.between?(5, 7)
        end
      end
    end

    self
  end

  def empty?(pos)
    self[pos].nil?
  end

  def render
    # system "clear"
    print "   "
    # 8.times { |i| print " #{(97 + i).chr.upcase} " }
    8.times { |i| print " #{i} " }
    puts
    @board.each_with_index do |row, i|
      print " #{i} "
      row.each_with_index do |piece, j|
        background = (i + j).even? ? :on_yellow : :on_white
        print(piece.nil? ? "   ".send(background) : 
          " #{piece.display[piece.color]} ".send(background))
      end
      puts " #{i} " 
    end

    print "   "
    # 8.times { |i| print " #{(97 + i).chr.upcase} " }
    8.times { |i| print " #{i} " }

    puts
  end

  def dup
    new_board = Board.new(false)

    @board.flatten.compact.each do |piece|
      new_pos = piece.pos.dup

      new_board[new_pos] = Piece.new(new_board, color: piece.color,
                                                pos: new_pos,
                                                kinged: piece.kinged)
    end

    new_board
  end
end

if $PROGRAM_NAME == __FILE__
  new_board = Board.new(true)
  # p new_board.board.flatten.length
  
  # Board#dup test
  dup_board = new_board.dup
  # p new_board.object_id
  # p dup_board.object_id
  dup_board[[2, 1]].perform_slide([3, 2])  
  new_board.render
  dup_board.render
end