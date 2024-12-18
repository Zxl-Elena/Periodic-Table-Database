#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

OUTPUT() {
  if [[ -z $REARCH_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read -r atomic_number atomic_mass melting_point boiling_point symbol name type <<< "$REARCH_RESULT"  
    result="The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    echo "$result"
  fi
}

if [[ $# -eq 0 ]]
then
  echo -e "Please provide an element as an argument."
else
  for arg in "$@"
  do
    if [[ $arg =~ ^[1-9]+$ ]]
    then
      REARCH_RESULT=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE properties.atomic_number = $arg;")
      OUTPUT
    elif [[ $arg =~ ^[a-zA-Z]{1,2}$ ]]
    then
      REARCH_RESULT=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE symbol = '$arg';")
      OUTPUT
    elif [[ $arg =~ ^[a-zA-Z]+$ ]]
    then
      REARCH_RESULT=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE name = '$arg';")
      OUTPUT
    fi
  done
fi