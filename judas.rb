#!/bin/ruby

=begin
judas Denounce your colleagues
Copyright (C) 2020  Mathias Schmitt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
=end

# frozen_string_literal: true

require 'optparse'

# This class is used to handle letters, their postion and their representation.
class Letter
  attr_reader :representation, :letter
  attr_accessor :correct_position

  def initialize letter
    @letter = letter
    @correct_position = false
    @representation = File.readlines('letters' + '/' + letter, chomp: true).map! { |line| line.split '' }
  end

  def change_letter new_letter
    initialize new_letter
  end

  def to_s
    @representation.each { |line| line.join('') }.join "\n"
  end
end

VICTIMS_FILE_NAME = '.victims'
FINAL_NAME_SIZE = 18
FINAL_NAME_HEIGHT = 8
VERSION = '1.0.0'

ALPHABET = ('a'..'z').to_a
intro = true

def display_ascii array, header_space_top, header_space_small
  str = ''
  FINAL_NAME_HEIGHT.times do |i|
    array.each do |letter|
      str += "\e[31m" if letter.correct_position
      str += letter.representation[i].join('') unless letter.representation[i].nil?
      str += "\e[0m" if letter.correct_position
    end
    str += "\n"
  end

  puts header_space_top + str + header_space_small
end

def chose_victim condemned
  # Open or create file of previous victims
  previous_victims = []
  file_victims = File.open(VICTIMS_FILE_NAME, 'a+')

  file_victims.each_line { |name| previous_victims << name.downcase.strip }

  # If all victims have been betrayed, then remove the file and recreate it
  if previous_victims.size >= condemned.size
    file_victims.close
    File.delete VICTIMS_FILE_NAME
    file_victims = File.open(VICTIMS_FILE_NAME, 'a+')
    previous_victims = []
  end

  possible_victims = condemned - previous_victims
  victim = possible_victims.sample

  # Write victim in the file of previous_victims
  file_victims.puts victim
  file_victims.close

  victim
end

# VARIOUS COMMANDS

OptionParser.new do |parser|
  parser.banner = \
    "Usage: ruby judas.rb [OPTIONS]\n"\
    'Denounce you colleagues'

  parser.on('-h', '--help', 'This help message') { puts parser; exit }

  parser.on('-c', '--clean', 'Forget all previous sacrifices! You were nothing'\
      ' but pathetic insignificant worms not worthy of being remembered'\
      ' anyway!') do
    begin
      File.delete VICTIMS_FILE_NAME
      puts 'All previous victims were ereased from history and no living '\
        'creature will ever remember their pathetic worthless existence!'
    rescue
      puts 'No previous sacrifices to forget. Bring new ones!'
    end
    exit
  end

  parser.on('-n', '--no-intro', 'Skip the intro and directly condemn someone'\
      ' to the eternal raging volcanic fire of Schiehallion!') do
    intro = false
  end

  parser.on('-v', '--version', 'output version informations and exit') do
    puts \
      "judas #{VERSION}\n\n"\
      "Copyright (C) 2020 Mathias Schmitt\n"\
      "License GPL\n"\
      'This is free software, and you are welcome to change and'\
        " redistribute it\n"\
      "This program comes with ABSOLUTELY NO WARRANTY.\n"
    exit
  end
end.parse!

# HEADERS && MENU

if intro
  header = ''
  File.open('headers/header') { |f| header += "\n" + f.readlines.join('') }
  puts header

  percent = 0
  (1..100).each do |x|
    case x
    when 60..75
      sleep 0.1
    when 78...87
      sleep 0.5
    when 88
      sleep 2
    else
      sleep 0.05
    end

    cariage_returns = 200
    dl_bar = x / 2
    spaces = 50 + 5
    print "#{"\r" * cariage_returns}#{' ' * spaces}#{percent += 1}%"
    print "#{"\r" * cariage_returns}#{'=' * dl_bar}>"
  end
  print "#{"\r" * 200}#{' ' * 100}"

  File.readlines('headers/space').each { |l| puts l; sleep 0.1 }
  File.readlines('headers/header2').each { |l| puts l; sleep 0.1 }
  sleep 3
end

# RANDOM VICTIM CHOICE

condemned = []
File.open('condemned', 'r') { |f| condemned = f.readlines(chomp: true) }
condemned.each(&:downcase)

victim = chose_victim(condemned)
victim_letters = victim.split ''
victim_indexes = (0...victim_letters.length).to_a

# array of 20 random letters
final_name_letters = []
FINAL_NAME_SIZE.times.with_index { final_name_letters << Letter.new(ALPHABET.sample) }

# Compute the number of letters to remove every turn
to_remove = FINAL_NAME_SIZE - victim.length
ratio = (to_remove.to_f / victim.length).ceil + 1

# MAIN ALGO

header_space_top = ''
File.open('headers/space_top') { |f| header_space_top += "\n" + f.readlines.join('') }

header_space_small = ''
File.open('headers/small_space') { |f| header_space_small += "\n" + f.readlines.join('') }

can_place_one = true
place_one_forced = false
current_ratio = 0.0
removed = 0.0
placed = 0.0
loop do
  break if victim_indexes.length.zero?

  # We can place a character if we removed enough useless characters.
  current_ratio = (removed / placed).floor if placed != 0.0
  can_place_one = true if current_ratio > ratio

  # All useless letters have been removed. Force filling the correct characters
  # to avoid useless suspense while only a few letters are missing.
  place_one_forced = removed >= (FINAL_NAME_SIZE - victim.length)

  3.times do
    # Randomize letters which are not placed yet
    final_name_letters.each { |l| l.change_letter ALPHABET.sample unless l.correct_position }
    display_ascii final_name_letters, header_space_top, header_space_small
    sleep 0.2
    puts  `clear`
  end

  if !can_place_one && to_remove.positive?
    final_name_letters.pop
    removed += 1
    to_remove -= 1
  elsif place_one_forced || can_place_one
    # Choose a random letter of the victim and add it to the final array
    index = rand victim_indexes.length
    letter_index = victim_indexes[index]
    letter = victim_letters[letter_index]
    victim_indexes.delete_at index

    final_name_letters[letter_index].change_letter letter
    final_name_letters[letter_index].correct_position = true
    placed += 1
    can_place_one = false

    display_ascii final_name_letters, header_space_top, header_space_small
    sleep 0.2
    puts `clear`
  end
end

final_name_letters.pop while final_name_letters.length > victim.length

display_ascii final_name_letters, header_space_top, header_space_small
