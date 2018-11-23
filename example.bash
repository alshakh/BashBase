#!/usr/bin/env bash
# load the lib
source "$(dirname "$0")/base.bash"


db_file=/tmp/example.db
rm "$db_file"
touch "$db_file" # empty db




bb_db_open "$db_file"






#======= constructing entries ========
echo "# constructing entry from  'firstname=john M.' 'lastname=smith'"
entry_0="$( bb_db_construct_entry "firstname=john M." "lastname=smith"  )"
echo "$entry_0"
#--> firstname:!:john M.:%:lastname:!:smith


#======= extracting values from entreis ========
echo
echo "# extracting 'firstname' from previous entry"
bb_db_extract_value_from_entry "$entry_0" 'firstname'
#--> john M.
echo "# extracting 'lastname' from previous entry"
bb_db_extract_value_from_entry "$entry_0" 'lastname'
#--> smith


#======= querying db ========
echo 
echo "# quering db for 'lastname=smith' without db entry"
bb_db_query "lastname=smith"
# NOTHING


echo "# quering db for 'lastname=smith' after inserting entry to db"
bb_db_commit_entry "$entry_0"
bb_db_query "lastname=smith"
#--> firstname:!:john M.:%:lastname:!:smith

echo "# add a different entry to db, same lastname"
bb_db_commit_entry "$(bb_db_construct_entry "firstname=jena K." "lastname=smith")"

echo "# quering db for 'lastname=smith'"
bb_db_query "lastname=smith"
#--> firstname:!:john M.:%:lastname:!:smith
#--> firstname:!:jena K.:%:lastname:!:smith

echo "# quering is actually regex (gawk rules) with 'lastname=s.*'"
bb_db_query "lastname=s.*"
#--> firstname:!:john M.:%:lastname:!:smith
#--> firstname:!:jena K.:%:lastname:!:smith

echo "# quering is actually regex (gawk rules) with 'lastname=s.*' and 'firstname=jena.*'"
bb_db_query "lastname=s.*" "firstname=jena.*"
#--> firstname:!:jena K.:%:lastname:!:smith


#======= deleting db ========
echo 
echo "# dump whole db"
bb_db_dump 
#--> firstname:!:john M.:%:lastname:!:smith
#--> firstname:!:jena K.:%:lastname:!:smith


echo "# deleting jena's entry"
bb_db_delete_entry "$(bb_db_query "firstname=jena.*" | head -n 1)"

echo "# dump whole db"
bb_db_dump 
#--> firstname:!:john M.:%:lastname:!:smith


#======= modifying entries db ========
echo 
echo "# get john smith entry"
echo "$entry_0"
#--> firstname:!:john M.:%:lastname:!:smith

echo "# add a field without commiting"
bb_db_modify_entry "$entry_0" "age" "42"
#--> firstname:!:john M.:%:lastname:!:smith:%:age:!:42

echo "# entry did not change in db"
bb_db_query "lastname=smith" "firstname=john.*"
#--> firstname:!:john M.:%:lastname:!:smith

echo "# change lastname without commiting"
bb_db_modify_entry "$entry_0" "lastname" "doe"
#--> firstname:!:john M.:%:lastname:!:doe


echo "# change lastname and commit "
bb_db_modify_entry_and_commit "$entry_0" "lastname" "doe"

echo "# dump whole db"
bb_db_dump
#--> firstname:!:john M.:%:lastname:!:doe

