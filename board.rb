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

  def empty?(pos)
    self[pos].nil?
  end

  def render
    # system "clear"
    print "   "
    8.times { |i| print " #{(97 + i).chr.upcase} " }
    puts
    @board.each_with_index do |row, i|
      print " #{i + 1} "
      row.each_with_index do |piece, j|
        background = (i + j).even? ? :on_white : :on_yellow
        print(piece.nil? ? "   ".send(background) : 
          " #{piece.display[piece.color]} ".send(background))
      end
      puts " #{i + 1} " 
    end

    print "   "
    8.times { |i| print " #{(97 + i).chr.upcase} " }
    puts
  end

  private
    
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
end

if $PROGRAM_NAME == __FILE__
  new_board = Board.new(true)
  
  # Board#dup test
  # dup_board = new_board.dup
  # p new_board.object_id
  # p dup_board.object_id
  # dup_board[[2, 1]].perform_slide([3, 2])  
  # new_board.render
  # dup_board.render

  # TEST SETUP
  new_board[[4, 3]] = Piece.new(new_board, color: :black, pos: [4, 3])
  new_board[[3, 6]] = Piece.new(new_board, color: :red, pos: [3, 6])
  new_board.render

  # SLIDE MOVES TEST
  # p new_board[[2, 1]].valid_slide_moves == [[3, 0], [3, 2]]
  
  # JUMP MOVES TEST
  # p new_board[[2, 7]].valid_jump_moves == [[4, 5]]
  # p new_board[[5, 2]].valid_jump_moves == [[3, 4]]

  # PERFORM MOVES TEST
  new_board[[1, 0]] = nil
  new_board.render
  new_board[[5, 4]].perform_moves([[5, 4], [3, 2], [4, 1]])
  new_board[[5, 4]].perform_moves([[5, 4], [3, 2], [1, 0]])
  new_board.render
end