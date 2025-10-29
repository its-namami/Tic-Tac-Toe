# frozen_array_literal: true

# This is a class for players that stores moves
class Player
  attr_reader :name

  def initialize
    @name = gets.chomp
  end
end
