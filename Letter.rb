LETTERS_FOLDER = 'letters'

class Letter
    attr_reader :width, :height, :representation, :letter
    attr_accessor :correct_position

    def initialize(letter)
        @letter = letter
        @correct_position = false
        @representation = File.read LETTERS_FOLDER + '/' + letter
        @height = @representation.count "\n"
        @width = @representation.length / @height
        @representation = @representation.split "\n"
        @representation.each_with_index do
            |r, i| @representation[i] = r.split ''
        end
    end

    def change_letter(new_letter)
        initialize new_letter
    end

    def inspect
        ret = ['']
        @representation.each_with_index do |line, index|
            ret << line.join('')
        end
        ret.join "\n"
    end

    def to_s
        ret = ['']
        @representation.each_with_index do |line, index|
            ret << line.join('')
        end
        ret.join "\n"
    end
end
