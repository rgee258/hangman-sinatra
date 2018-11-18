require 'sinatra'
require 'sinatra/reloader' if development?

def new_word
  # All reading for the 5desk.txt file is done here only.
  word_list = File.readlines("5desk.txt")
  loop do
    rand_num = rand(word_list.length - 1)
    word = word_list.sample.strip!
    if (word.length > 4 && word.length < 13)
      return word.upcase
    end
  end
end

def set_word(word)
  word_arr = []
  word.each_char do |c|
    word_arr.push(c)
  end
  word_arr
end

def set_display(word)
  # Set up all of the game's instance variables necessary for the new game.
  display = []
  word.each_char do |c|
    display.push("_")
  end
  display
end

# Methods for game handling

def game_finished?
  finished = true
  # Check for any display placeholders, if they exit the game is not finished.
  @@word_display.each do |c|
    if (c == "_")
      finished = false
      break
    end
  end

  # If there are no placeholder marks and guesses remaining, then the player has won and the game is finished.
  if (finished)
    if (@@guesses_remaining > 0)
      @@game_status = "win"
    end
  # There are still placeholders, so if we have no more guesses then the player has lost and the game is finished.
  else
    if (@@guesses_remaining == 0)
      @@game_status = "lose"
      finished = true
    end
  end
  finished
end

def end_game
  if (@@game_status == "win")
    "You win, good job guessing that word! <br> The game has reset so type in a new guess and play again!"
  elsif (@@game_status == "lose")
    "The word you were trying to guess was: <br> #{@@word.join} <br> The game has reset so type in a new guess and play again!"
  end
end

def reset_game
  @@guesses_remaining = 6
  @@word = set_word(new_word)
  @@word_display = set_display(@@word.join)
  @@used_letters = []
  @@game_status = "ongoing"
end

def guess(letter)
  if letter.length > 1
    return "You need to guess a single letter, try again."
  # Ensure that our single character is a letter and not otherwise.
  elsif /[a-zA-Z]/.match(letter).nil?
    return "That's not a valid letter, try again."
  else
    letter = letter.upcase
    unless (letter_repeated?(letter))
      correct = false
      # Check this letter against our word, replacing the correct letters in their respective positions.
      @@word.each_with_index do |c, i|
        if (letter == c)
          correct = true
          @@word_display[i] = letter
        end
      end
      if (correct)
        @@used_letters.push(letter)
      # If the letter is not correct, add it to the used letters and reduce the guess counter.
      else
        @@used_letters.push(letter)
        @@guesses_remaining -= 1
      end
    else
      return "You already used that letter, try a different one!"
    end
  end
  "\nGuess: #{letter}"
end

def letter_repeated?(letter)
# Check against our used letters and ask for a new letter if it's been repeated.
  @@used_letters.each do |c|
    if (letter == c)
      return true
    end
  end
  false
end

@@guesses_remaining = 6
@@word = set_word(new_word)
@@word_display = set_display(@@word.join)
@@used_letters = []
@@game_status = "ongoing"

get '/' do
  turn_guess = params["guess"]
  # Maybe try passing as local variables instead?
  @guess = guess(turn_guess) unless turn_guess.nil?
  @word = @@word.join
  @word_display = @@word_display.join(" ")
  @guesses_remaining = @@guesses_remaining
  @used_letters = @@used_letters.join(" ")
  case @@guesses_remaining
  when 6
    @hm_image = "hm1.png"
  when 5
    @hm_image = "hm2.png"
  when 4
    @hm_image = "hm3.png"
  when 3
    @hm_image = "hm4.png"
  when 2
    @hm_image = "hm5.png"
  when 1
    @hm_image = "hm6.png"
  when 0
    @hm_image = "hm7.png"
  else
    @hm_image = "hm1.png"
  end
  if (game_finished?)
    @results = end_game
    reset_game
  else
    @results = @guess
  end
  erb :index
end