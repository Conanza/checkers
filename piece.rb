require "colorize"

class InvalidMoveError < ArgumentError
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

  def initialize(board, user_options)
    options = { color: nil, pos: nil, kinged: false }.merge(user_options)

    @color, @pos, @kinged = options[:color], options[:pos], options[:kinged]
    @board = board
    @dir = @color == :black ? 1 : -1
  end

  def display
    { red: "☻".red, black: "☻".black }
  end

  def perform_moves(seq)
    valid_move_seq?(seq) ? perform_moves!(seq) : raise(InvalidMoveError)
  end

  protected

    def perform_moves!(seq)
      if seq.length == 2
        return if perform_slide(seq[1])
        raise InvalidMoveError unless perform_jump(seq[1]) 
      else
        seq[1..-1].each do |jump|
          raise InvalidMoveError unless perform_jump(jump)
        end
      end

      nil
    end

  private

    def jump_moves
      row, col = @pos

      jumps = if @kinged 
        KING_DIFFS[:jumps].map { |(drow, dcol)| [row + drow, col + dcol] }
      else
        MOVE_DIFFS[:jumps].map { |(drow, dcol)| [row + (drow * @dir), col + dcol] }
      end

      jumps.select do |jump|
        jumped_pos(pos, jump).all? { |coord| coord.between?(0,7) }
      end.reject { |jump| @board.empty?(jumped_pos(pos, jump)) }
        .reject { |jump| @board[jumped_pos(pos, jump)].color == color }
    end

    def jumped_pos(start_pos, end_pos)
      start_row, start_col = start_pos
      end_row, end_col = end_pos

      [(start_row + end_row) / 2, (start_col + end_col) / 2]
    end
    
    def perform_jump(end_pos)
      if valid_jump_moves.include?(end_pos)      
        pos_between = jumped_pos(pos, end_pos)

        @board[pos] = nil
        @board[pos_between] = nil
        @pos = end_pos
        @board[end_pos] = self
        @kinged = true if promote?

        true
      else
        false
      end
    end
    
    def perform_slide(end_pos)
      if valid_jump_moves.empty? && valid_slide_moves.include?(end_pos)

        @board[pos] = nil
        @pos = end_pos
        @board[end_pos] = self
        @kinged = true if promote?

        true
      else
        false
      end
    end
    
    def promote?
      color == :black && pos[0] == 7 || color == :red && pos[0] == 0
    end

    def slide_moves
      row, col = @pos

      if @kinged
        KING_DIFFS[:slides].map { |(drow, dcol)| [row + drow, col + dcol] }
      else
        MOVE_DIFFS[:slides].map { |(drow, dcol)| [row + (drow * @dir), col + dcol] }
      end
    end

    def valid_move_seq?(seq)
      dup_board = @board.dup
      dup_piece = Piece.new(
        dup_board, 
        color: self.color, 
        kinged: self.kinged,
        pos: self.pos
      )

      begin 
        dup_piece.perform_moves!(seq)

        true
      rescue InvalidMoveError => e
        puts e.message

        false
      end
    end

    def valid_jump_moves
      jump_moves.select { |end_pos| valid_pos?(end_pos) }
    end

    def valid_pos?(pos)
      pos.all? { |coord| coord.between?(0, 7) && @board.empty?(pos) }
    end 

    def valid_slide_moves
      slide_moves.select { |end_pos| valid_pos?(end_pos) }
    end
end
