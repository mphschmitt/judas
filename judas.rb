require_relative 'Letter'


HEADER_FILE = 'headers/header'
HEADER_SPACE = 'headers/space'
HEADER_SMALL_SPACE = 'headers/small_space'
HEADER_SPACE_TOP = 'headers/space_top'
HEADER_GROUND = 'headers/header2'

FINAL_NAME_SIZE = 18
FINAL_NAME_HEIGHT = 8

VICTIMS = [
    'quentin',
    'thomas',
    'bachir',
    'axel',
    'matthieu',
    'paul',
    'seif',
    'paul',
    'mathias'
]

# Alphabet
$ALPHABET = ('a'..'z').to_a
$ALEPHBET = []

index = 0
('a'..'z').each do |letter|
    $ALEPHBET[index] = Letter.new letter
    puts $ALEPHBET[index]
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
#                               HEADERS && MENU
###############################################################################

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

###############################################################################
#                               HEADERS && MENU
###############################################################################

###############################################################################
#                               RANDOM VICTIM CHOICE
###############################################################################

# Choose victim and obtain its letters.
# Create an array of index to select random letter only once later on.
victim = VICTIMS[rand VICTIMS.length]
victim_letters = victim.split ''
victim_indexes = (0...victim_letters.length).to_a

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
#                               RANDOM VICTIM CHOICE
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
