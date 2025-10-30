# frozen_string_literal: true

# This is a class for players that stores moves
class Player
  attr_reader :name, :moves

  def initialize(name)
    @name = name
    @moves = Array.new(9, false)
  end

  def move(position)
    raise ArgumentError unless (0..moves.size).include?(position) && moves[position] == false

    moves[position] = true

    position
  end

  private

  attr_writer :moves
end
