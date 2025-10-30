# frozen_string_literal: true

require_relative 'player'

# This is a class that controlls the game and players
class Game
  attr_reader :player1, :player2, :current_player

  def initialize
    name_player1 = ask_name('Player 1')
    @player1 = Player.new(name_player1)
    name_player2 = ask_name('Player 2')
    @player2 = Player.new(name_player2)
    @current_player = player1

    input_command
  end

  private

  COMMANDS = {
    'stop' => { params?: false },
    'move' => { params?: true },
    'show' => { params?: false }
  }.freeze

  def move_player(position)
    current_player.move(position)
  rescue ArgumentError
    puts 'Bad Position!'
  end

  def show_board
    puts player1.moves
    puts player2.moves
  end

  def end_game
    puts 'See you next time!'
  end

  def analyze_command(command)
    ask_move if command == 'move'
    show_board if command == 'show'
    return end_game if command == 'stop'

    puts
    input_command
  end

  def analyze_params_command(command)
    command_type, command_params = command.split(':')
    move_player(command_params.to_i) if command_type == 'move'

    puts
    input_command
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

  def warn_bad_input
    print 'Warning: Bad Input [PRESS ENTER TO CONTINUE]'
    gets
    puts
  end

  def input_command
    command = ask_command

    if COMMANDS.include?(command)
      analyze_command(command)
    elsif COMMANDS.select { |_, v| v[:params?] }.include?(command.split(':')[0])
      analyze_params_command(command)
    else
      warn_bad_input
      input_command
    end
  end
end
