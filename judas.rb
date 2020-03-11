require_relative 'Letter'


HEADER_FILE = 'headers/header'
HEADER_SPACE = 'headers/space'
HEADER_SMALL_SPACE = 'headers/small_space'
HEADER_SPACE_TOP = 'headers/space_top'
HEADER_GROUND = 'headers/header2'

VICTIMS_FILE_NAME = ".victims"

FINAL_NAME_SIZE = 18
FINAL_NAME_HEIGHT = 8

VICTIMS = [
    'quentin',
    'thomas',
    'bachir',
    'axel',
    'matthieu',
    'seif',
    'paul',
    'mathias',
    'makram'
]

# Alphabet
$ALPHABET = ('a'..'z').to_a
$ALEPHBET = []

index = 0
('a'..'z').each do |letter|
    $ALEPHBET[index] = Letter.new letter
    index += 1
end

def randomize(array)
    array.each do |l|
        next if l.correct_position
        l.change_letter $ALPHABET[rand $ALPHABET.length]
    end
end

def display_ascii(array)
    display = []

    FINAL_NAME_HEIGHT.times.with_index do |line|
        str = ''
        array.each do |letter|
            str << "\e[31m" if letter.correct_position
            unless letter.representation[line].nil?
                str << letter.representation[line].join('')
            end
            str << "\e[0m" if letter.correct_position
        end
        display << str
    end

    f = File.open HEADER_SPACE_TOP
    header = "\n" << f.readlines.join('')
    puts header
    puts display.join "\n"
    f = File.open HEADER_SMALL_SPACE
    header = "\n" << f.readlines.join('')
    puts header
end

###############################################################################
#                               VARIOUS COMMANDS
###############################################################################

if ARGV[0] == "--help" || ARGV[0] == "-h"
  puts "-c, --clean"
  puts "\tForget all previous sacrifices! You were nothing but pathetic insignificant worms not worthy of being remembered anyway!"
  puts "--no-intro"
  puts "\tSkip the intro and directly condemn someone to the eternal raging volcanic fire of Schiehallion!"
  puts "-h, --help"
  puts "\tIsn't it obvious?"
  return
end

if ARGV[0] == "--clean" || ARGV[0] == "-c"
  begin
    File.delete VICTIMS_FILE_NAME
    puts "All previous victims were ereased from history and no living creature will ever remeber their pathetic worthless existence!"
  rescue
    puts "No previous sacrifices to forget. Bring new ones!"
  end
  return
end

###############################################################################
#                               HEADERS && MENU
###############################################################################

unless ARGV[0] == "--no-intro"
    f = File.open HEADER_FILE
    header = "\n" << f.readlines.join('')
    puts header

    percent = 0
    (1..100).each do |x|
        if x > 89 || x < 60 || (x > 78 && x < 87)
            sleep 0.05
        elsif x > 88
            sleep 2
        elsif x > 75
            sleep 1
        elsif x > 60
            sleep 0.1
        end

        cariage_returns = 200
        dl_bar = x / 2
        spaces = 50 + 5
        print "#{"\r" * cariage_returns}#{' ' * (spaces)}#{percent+=1}%"
        print "#{"\r" *  cariage_returns}#{"=" * dl_bar}>"
    end
    print "#{"\r" *  200}#{" " * 100}"

    f = File.readlines(HEADER_SPACE).each do |l|
        puts l
        sleep 0.1
    end
    f = File.readlines(HEADER_GROUND).each do |l|
        puts l
        sleep 0.1
    end
    sleep 3
end

###############################################################################
#                               RANDOM VICTIM CHOICE
###############################################################################

# Open or create file of previous victims
previous_victims = []
file_victims = File.open(VICTIMS_FILE_NAME, 'a+')

file_victims.each_line do |name|
  previous_victims << name.strip
end

# If all victims have been betrayed, then remove the file and recreate it!
if previous_victims.size >= VICTIMS.size
  file_victims.close unless file_victims.nil? or file_victims.closed?
  File.delete VICTIMS_FILE_NAME
  file_victims = File.open(VICTIMS_FILE_NAME, 'a+')
  previous_victims = []
end

# Choose victim and obtain its letters.
# Create an array of index to select random letter only once later on.
victims_cpy = VICTIMS.dup
while true
  victim = victims_cpy[rand victims_cpy.length]
  break if !previous_victims.include? victim
  victims_cpy.delete victim
end
victim_letters = victim.split ''
victim_indexes = (0...victim_letters.length).to_a

# Write victim in the file of previous_victims
file_victims.puts victim

# empty array of 20 letters
final_name_letters = []
FINAL_NAME_SIZE.times.with_index do |line|
    final_name_letters << Letter.new($ALPHABET[rand $ALPHABET.length])
end

display_ascii final_name_letters

# Compute the number of letters to remove every turn
to_remove = FINAL_NAME_SIZE - victim.length
ratio = (to_remove.to_f / victim.length).ceil + 1

###############################################################################
#                               MAIN ALGO
###############################################################################

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
    place_one_forced = removed >= FINAL_NAME_SIZE - victim.length

    3.times do
        randomize final_name_letters
        display_ascii final_name_letters
        sleep 0.2
        puts  `clear`
    end

    if !can_place_one && to_remove > 0 # && rand(10) > 4
        final_name_letters.pop
        removed += 1
        to_remove -= 1
    elsif place_one_forced || can_place_one # && rand(10) > 3
        # Choose a random letter of the victim and add it to the final array
        index = rand victim_indexes.length
        letter_index = victim_indexes[index]
        letter = victim_letters[letter_index]
        victim_indexes.delete_at index

        final_name_letters[letter_index].change_letter letter
        final_name_letters[letter_index].correct_position = true
        placed += 1
        can_place_one = false

        display_ascii final_name_letters
        sleep 0.2
        puts `clear`
    end
end

while final_name_letters.length > victim.length
    final_name_letters.pop
end

display_ascii final_name_letters
