# frozen_string_literal: true

require_relative 'player'

# This is a class that controlls the game and players
class Game
  attr_reader :player1, :player2, :current_player, :other_player

  def initialize
    name_player1 = ask_name('Player 1')
    @player1 = Player.new(name_player1)
    name_player2 = ask_name('Player 2')
    @player2 = Player.new(name_player2)
    @current_player = player1
    @other_player = player2

    input_command
  end

  private

  attr_writer :current_player, :other_player

  WINNING_COMBINATIONS = [
    [0, 1, 2], # top row
    [3, 4, 5], # middle row
    [6, 7, 8], # bottom row
    [0, 3, 6], # left column
    [1, 4, 7], # middle column
    [2, 5, 8], # right column
    [0, 4, 8], # diagonal
    [2, 4, 6]  # other diagonal
  ].freeze

  COMMANDS = {
    'stop' => { params?: false },
    'move' => { params?: true },
    'show' => { params?: false }
  }.freeze

  def move_player(position)
    raise ArgumentError if other_player.moves[position] == true

    current_player.move(position)
    swap_players_order
  rescue ArgumentError
    warn 'Bad Position'
  end

  # 0 1 2
  # 1 2 1
  # 2 0 0
  def board
    player1.moves.zip(player2.moves).map do |a, b|
      if a
        1
      else
        b ? 2 : 0
      end
    end
  end

  def end_game
    puts 'See you next time!'
  end

  def analyze_command(command)
    ask_move if command == 'move'
    puts board.inspect if command == 'show'
    return end_game if command == 'stop'

    puts
    input_command
  end

  def strict_to_i(str)
    raise ArgumentError unless str.match?(/\A\d+\z/)

    str.to_i
  end

  def analyze_params_command(command)
    command_type, command_params = command.split(' ')
    begin
      move_player(strict_to_i(command_params)) if command_type == 'move'
    rescue ArgumentError
      warn 'There is a non-integer character, expected only intigers'
    ensure
      puts
      input_command
    end
  end

  def ask_move
    print "Write the name for the position you wanna move\n>>> "
    position = gets.to_i
    puts
    move_player(position)
  end

  def ask_name(player)
    print "Write the name for #{player}\n>>> "
    name = gets.chomp
    puts
    name
  end

  def ask_command
    print "Input the command #{available_commands}\n>>> "
    command = gets.chomp
    puts
    command
  end

  def available_commands
    COMMANDS.each.reduce('') do |str, (key, _)|
      str + "#{key} "
    end
  end

  def warn(warning = 'Bad Input')
    print "Warning: #{warning} [PRESS ENTER TO CONTINUE]"
    gets
    puts
  end

  def input_command
    command = ask_command

    if COMMANDS.include?(command)
      analyze_command(command)
    elsif COMMANDS.select { |_, v| v[:params?] }.include?(command.split(' ')[0])
      analyze_params_command(command)
    else
      warn
      input_command
    end
  end

  def swap_players_order
    p1 = current_player
    self.current_player = other_player
    self.other_player = p1
  end
end
