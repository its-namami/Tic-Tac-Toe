# frozen_string_literal: true

require_relative 'player'

# This is a class that controlls the game and players
class Game
  attr_reader :player1, :player2

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

  attr_accessor :current_player, :other_player, :game_over

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
    'move' => { params?: true }
  }.freeze

  def players_tie?
    board.reject { |square| square == '-' }.size == 9
  end

  def handle_outcome(player)
    if player_win?(player)
      puts "Congrats #{player.name}, you won!"
      pp_board
      self.game_over = true
    elsif players_tie?
      puts "It's a tie!"
      pp_board
      self.game_over = true
    end
  end

  def player_win?(player)
    moves = player.moves.each.with_index.filter_map do |move, index|
      index if move
    end

    WINNING_COMBINATIONS.any? do |combo|
      combo.all? { |index| moves.include?(index) }
    end
  end

  def swap_players_order
    p1 = current_player
    self.current_player = other_player
    self.other_player = p1
  end

  def move_player(position)
    raise ArgumentError if other_player.moves[position] == true

    current_player.move(position)
    handle_outcome(current_player)
    swap_players_order
  rescue ArgumentError
    warn 'Bad Position'
  end

  def pp_board
    puts "\nCurrent board"

    board.each.with_index do |square, index|
      if ((index + 1) % 3).zero?
        puts square
      else
        print "#{square} "
      end
    end

    puts
  end

  def board
    player1.moves.zip(player2.moves).map do |a, b|
      if a
        'x'
      else
        b ? 'o' : '-'
      end
    end
  end

  def end_game
    puts 'See you next time!'
  end

  def analyze_command(command)
    ask_move if command == 'move'
    pp_board if command == 'show'
    return end_game if command == 'stop'

    return if game_over

    puts
    input_command
  end

  def strict_to_i(str)
    raise ArgumentError unless str.match?(/\A\d+\z/)

    str.to_i
  end

  def analyze_params_command(command)
    command_type, command_params = command.split(' ')
    move_player(strict_to_i(command_params) - 1) if command_type == 'move'
  rescue ArgumentError
    warn 'There is a non-integer character, expected only intigers'
  ensure
    unless game_over
      puts
      input_command
    end
  end

  def ask_move
    print "Write the number of the position you wanna move\n>>> "
    position = gets.chomp
    puts
    move_player(strict_to_i(position) - 1)
  end

  def ask_name(player)
    print "Write the name for #{player}\n>>> "
    name = gets.chomp
    puts
    name
  end

  def ask_command
    print "Input a command (#{available_commands.strip})\n>>> "
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
    puts "Warning: #{warning} [PRESS ENTER TO CONTINUE]"
    gets
    puts
  end

  def player_turn
    "It's #{current_player.name}'s turn now!"
  end

  def pp_info
    puts player_turn
    pp_board
  end

  def input_command
    pp_info
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
end
