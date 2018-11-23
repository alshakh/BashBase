#!/usr/bin/env  bash

FS=':%:' # field separator
KVS=':!:' # key-value separator

bb_open_db="undef"
bb_db_open ()  {
    local db_file="$1"
    [[ ! -f "$db_file" ]] && touch "$db_file"
    bb_open_db="$db_file"
}

##
bb_db_construct_entry () {
    # keyvalue pairs key=value key=value
    for kv in "$@" ; do echo "$kv" ; done | awk -v kvs="$KVS" -v fs="$FS" 'BEGIN{ORS=fs}{ sub("=",kvs) ; print }' | awk -v fs="$FS" '{ sub( fs "$", "") ; print }'
}

bb_db_commit_entry () {
    [[ "$bb_open_db" == "undef" ]] && echo 'no defined db' && exit 2
    #####
    local entry="$1"
    echo "$entry" >> "$bb_open_db"
}

bb_db_entry_to_readable_lines () {
    local entry="$1"
    echo "$entry" | awk -v fs="$FS" -v kv="$KVS" '{ gsub(fs,"\n") ; gsub(kv,"=") ; print }'
}

bb_db_split_entry_to_lines () {
    local entry="$1"
    echo "$entry" | awk -v fs="$FS" '{ gsub(fs,"\n") ; print }'
}

bb_db_query () {
    # key=value key=value .. ==> list of matching entries
    [[ "$bb_open_db" == "undef" ]] && echo 'no defined db' && exit 2
    #####

    local db="$(cat "$bb_open_db")"
    for querykv in "$@" ; do
        db="$(echo "$db" | awk -v querykv="$querykv" -v kvs="$KVS" -v fs="$FS" 'BEGIN{ sub("=",kvs,querykv) } {if ( $0 ~ "(^|" fs ")" querykv "($|" fs ")" ) { print }  }')"
    done
    echo "$db"
}

bb_db_extract_value_from_entry () {
    # entry keyname ==> value
    local entry="$1"
    local key="$2"

    echo "$entry" | awk -F "$FS" -v kvs="$KVS" -v keyname="$key" '{ for ( i = 1 ; i <= NF ; ++i ) { if ( $i ~ "^" keyname kvs ) { sub( "^" keyname kvs , "" , $i ) ; print $i ; break } } }'
}

bb_db_delete_entry () {
    [[ "$bb_open_db" == "undef" ]] && echo 'no defined db' && exit 2
    #####
    local entry="$1"

    local tmpfile=/tmp/$RANDOM$RANDOM$RANDOM
    cp "$bb_open_db" $tmpfile
    cat $tmpfile | awk -v entry="$entry" '{ if ( $0 != entry ) { print } }' > "$bb_open_db"
    rm -f "$tmpfile"
}

bb_db_modify_entry_and_commit () {
    # entry key newvalue    ==> new entry 
    # also, it will commit the change,
    # IT WILL NOT COMMIT THE CHANGES
    [[ "$bb_open_db" == "undef" ]] && echo 'no defined db' && exit 2
    #####
    local entry="$1"
    local keyname="$2"
    local newvalue="$3"

    bb_db_delete_entry  "$entry"
    local newentry="$(bb_db_modify_entry "$entry" "$keyname" "$newvalue")"
    bb_db_commit_entry  "$newentry"
}

bb_db_modify_entry () {
    # entry key newvalue    ==> new entry 
    # also, it will commit the change,
    # IT WILL NOT COMMIT THE CHANGES
    local entry="$1"
    local keyname="$2"
    local newvalue="$3"

    echo "$entry" | awk -F "$FS" -v kvs="$KVS" -v keyname="$keyname" -v newvalue="$newvalue" 'BEGIN{OFS=FS ; exist=0}{ for ( i = 1 ; i <= NF ; ++i ) { if ( $i ~ "^" keyname kvs  ) {exist=1 ;  $i = keyname kvs  newvalue } } }  END{ if ( exist == 0 ) { $0 = $0 FS keyname kvs newvalue } ; print $0 }'
}

bb_db_dump () {
    [[ "$bb_open_db" == "undef" ]] && echo 'no defined db' && exit 2
    #####
    cat "$bb_open_db"
}
