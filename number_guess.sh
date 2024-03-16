#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate secret number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Get username
echo "Enter your username:"
read USERNAME

# Get user id for given username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# If user id null
if [[ -z $USER_ID ]]
then
  # Insert new user into users table
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

  # If successful
  if [[ $INSERT_NEW_USER_RESULT == "INSERT 0 1" ]]
  then
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "An error occured. Please try again."
  fi
else
  # Get historic stats
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID;")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Guess secret number
echo "Guess the secret number between 1 and 1000:"
read GUESS

# Initalise guess counter
NUMBER_OF_GUESSES=1

# While guess is incorrect
while [[ $GUESS != $SECRET_NUMBER ]]
do
  # Check if guess is an integer
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    # If guess is too small
    echo "It's higher than that, guess again:"
  else
    # If guess is too large
    echo "It's lower than that, guess again:"
  fi

  # Read new guess
  read GUESS

  # Increment guess counter
  (( NUMBER_OF_GUESSES++ ))
done

# Insert the new game into database
INSERT_NEW_GAME_RESULT="$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")"

# If the insert was successful
if [[ $INSERT_NEW_GAME_RESULT == "INSERT 0 1" ]]
then
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
else
  echo $INSERT_NEW_GAME_RESULT
  echo "An error occured. Please try again."
fi