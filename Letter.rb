class Letter
    attr_reader :width, :representation

    def initialize(filename)
        @good_place = false
        @representation = File.read filename
        @height = @representation.count "\n"
        @representation = "\n" << @representation
        @width = @representation.length / @height - 1
    end

    def print
        puts @representation
    end
end

class Small_letter
    attr_accessor :correct_position, :char

    def initialize(char)
        @correct_position = false
        @char = char
    end

    def to_s
        @char
    end

    def inspect
        @char
    end
end