#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align -t -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"


RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
echo Enter your username:
read USERNAME

SELECT_DATA=$($PSQL "SELECT player_id, name FROM players where name = '$USERNAME'")
IFS='|' read -r PLAYER_ID NAME <<< "$SELECT_DATA"
guesses=()


GAME_ON(){
  echo -e "\nGuess the secret number between 1 and 1000:"
  read ANSWER
  guesses+=("$ANSWER") 

  until [[ $ANSWER =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read ANSWER
    guesses+=("$ANSWER") 
  done
  until [[ $ANSWER == $RANDOM_NUMBER ]]
  do
    if [[ $ANSWER > $RANDOM_NUMBER ]]; then
      echo -e "\nIt's lower than that, guess again:"
      read ANSWER
      guesses+=("$ANSWER") 
    else
      echo -e "\nIt's higher than that, guess again:"
      read ANSWER
      guesses+=("$ANSWER")
    fi
  done
}

SELECT_USERNAME=$($PSQL "SELECT name FROM players WHERE name = '$USERNAME'")
if [[ $SELECT_USERNAME ]]; then
  BEST_GAME=$($PSQL "SELECT MIN(best_game::INT) FROM games WHERE player_id = $PLAYER_ID")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(games_played) FROM games WHERE player_id = $PLAYER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  INSERT_USERNAME=$($PSQL "INSERT INTO players(name) VALUES('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi
GAME_ON
NUMBER_OF_GUESSES=${#guesses[@]}
INSERT_DATA=$($PSQL "INSERT INTO games(best_game, player_id) VALUES('$NUMBER_OF_GUESSES', $PLAYER_ID)")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
