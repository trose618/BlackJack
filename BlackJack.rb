class Card
	def initialize(name, value, suite, face_up = true)
		@name = name
		@value = value
		@suite = suite
		@face_up = face_up
	end

	def get_card_info
		puts @face_up == true ? "#{@name} of #{@suite}" : "Face down card"
	end

	def set_card_face_up (card_is_face_up)
		@face_up = card_is_face_up
	end

	def get_value
		@value
	end

	def set_value(value)
		@value = value
	end

end

class Deck
	$deck = []

	def initialize 
		for num in (2..10) do 

		hearts = Card.new(num.to_s, num, "Hearts", true)
		diamonds = Card.new(num.to_s, num, "Diamonds", true)
		clubs = Card.new(num.to_s, num, "Clubs", true)
		spades = Card.new(num.to_s, num, "Spades", true)

		$deck << hearts << diamonds << clubs << spades
		end

		faces = ["Jack", "Queen", "King", "Ace"]
		faces.each do |face| 
			if face == "Ace" 
				hearts = Card.new(face, 11, "Hearts", true)
				diamonds = Card.new(face, 11, "Diamonds", true)
				clubs = Card.new(face, 11, "Clubs", true)
				spades = Card.new(face, 11, "Spades", true)
				$deck << hearts << diamonds << clubs << spades
			else 
				hearts = Card.new(face, 10, "Hearts", true)
				diamonds = Card.new(face, 10, "Diamonds", true)
				clubs = Card.new(face, 10, "Clubs", true)
				spades = Card.new(face, 10, "Spades", true)
				$deck << hearts << diamonds << clubs << spades
			end
			
		end
	end

	def shuffle
		$deck = $deck.shuffle
	end

	def deal_card

		$deck.pop
	end

	def show_next
		$deck[$deck.length-1]
	end

	def print_deck
		$deck.each do |card|
			card.get_card_info
		end
	end

	def size
		$deck.size
	end
end

class PlayerCards

	def initialize (player_name)
		@player_name = player_name
		@cards = []
	end

	def hand_value
		sum = 0
		@cards.each do |card|
			sum += card.get_value
		end
		return sum
	end

	def name
		@name
	end

	def get_cards
		@cards
	end

	def read_cards
		@cards.each do |card|
			card.get_card_info
		end
	end

end

class BjTable

	def initialize(deck, p1_cards, p2_cards)
	@deck = deck
	@p1_cards = p1_cards
	@p2_cards = p2_cards
	end

	def deal_cards_to_players
		@p1_cards.get_cards << @deck.deal_card << @deck.deal_card
		@p2_cards.get_cards << @deck.deal_card << @deck.deal_card
		@p2_cards.get_cards[0].set_card_face_up(false)
		#deal with starting with 2 aces
		@p1_cards.get_cards[0].set_value(1) if @p1_cards.hand_value == 22
		@p2_cards.get_cards[0].set_value(1) if @p2_cards.hand_value == 22
	end

	def get_p1_cards
		@p1_cards
	end

	def get_p2_cards
		@p2_cards
	end

	def give_p1_card
		@p1_cards.get_cards << @deck.deal_card
	end

	def give_p2_card
		@p2_cards.get_cards << @deck.deal_card
	end

end

#set up

puts "Enter your name."
name = gets.chomp

deck = Deck.new
deck.shuffle

player_cards = PlayerCards.new(name)
dealer_cards = PlayerCards.new("Dealer")

table = BjTable.new(deck, player_cards, dealer_cards)
table.deal_cards_to_players


player_turn = true
bust = false
puts "\nEnter a command. E.g. 'help'. "
while player_turn
	
	print ">"
	command = gets.chomp
	case command
	when "help"
		puts "\nList of game commands:\nmy cards\ndealer's cards\nhit\nstay\nquit\n"

	when "my cards"
		puts ""
		table.get_p1_cards.read_cards
		puts "Value: #{table.get_p1_cards.hand_value}"

	when "dealer's cards"
		puts "\nDealer's cards:"
		table.get_p2_cards.read_cards

	when "hit"
		#add card to player's hand and show hand
		table.give_p1_card
		#check if ace needs to be reduced
		if table.get_p1_cards.hand_value > 21
			table.get_p1_cards.get_cards.each do |card|
				#set ace value from 11 to 1
				if card.get_value == 11
					card.set_value(1)
					break
				end
			end
		end
			
		table.get_p1_cards.read_cards
		puts "Value: #{table.get_p1_cards.hand_value}"
		#if they bust, end their turn, else continue 
		if table.get_p1_cards.hand_value > 21
			bust = true
			puts "BUST!\n" 
			player_turn = false
		end

	when "stand"
		player_turn = false
		#switch to dealer's turn
		#show dealer's cards
		#hit dealer and show their cards

	when "quit"
		bust = true
		player_turn = false
	else
		puts "Invalid command.\n"
	end
end

if bust
	puts "Dealer wins."

else
	puts "Dealer's turn."
	table.get_p2_cards.get_cards[0].set_card_face_up(true)
	#show dealer's hand
	puts "\nDealer's cards:"
	table.get_p2_cards.read_cards
	puts "Value: #{table.get_p2_cards.hand_value}\n "
	#while dealer's hand value is lower than p1's hand value
	if table.get_p2_cards.hand_value > table.get_p1_cards.hand_value
		puts "Dealer wins!"
	elsif table.get_p2_cards.hand_value == table.get_p1_cards.hand_value && table.get_p2_cards.hand_value == 21
		puts "Tie game!"
	else
		while table.get_p2_cards.hand_value < 21
			#delay 3 seconds
			sleep 3
			#hit
			table.give_p2_card
			if table.get_p2_cards.hand_value > 21
			table.get_p2_cards.get_cards.each do |card|
				#set ace value from 11 to 1
				if card.get_value == 11
					card.set_value(1)
					break
				end
			end
		end
			table.get_p2_cards.read_cards
			puts "hand value: #{table.get_p2_cards.hand_value}\n "
			#if bust, p1 wins
			if table.get_p2_cards.hand_value > 21
				puts "Dealer busts. #{name} wins!"
				break
			end
			#if greater than p1 hand, dealer wins
			if table.get_p2_cards.hand_value > table.get_p1_cards.hand_value
				puts "Dealer wins!"
				break
			end
			#if equals, it's a tie
			if(table.get_p2_cards.hand_value == table.get_p1_cards.hand_value)
				puts "Tie game!"
				break
			end
		end
	end
end