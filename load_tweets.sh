#!/bin/sh

# list all of the files that will be loaded into the database
# for the first part of this assignment, we will only load a small test zip file with ~10000 tweets
# but we will write are code so that we can easily load an arbitrary number of files
files='
test-data.zip
'

# these ports must match the ports in docker-compose.yml
port_denormalized=8888
port_normalized=8889

echo 'load normalized'
for file in $files; do
    # call the load_tweets.py file to load data into pg_normalized
    python3 load_tweets.py --db "postgresql+psycopg2://postgres:pass@localhost:$port_normalized/postgres" --inputs "$file"
done

echo 'load denormalized'
for file in $files; do
    # use SQL's COPY command to load data into pg_denormalized;
    # each line of the file is one JSON tweet, so we load it as a 1-column csv file
    # with quote/delimiter characters that never appear in the data;
    # the sed command removes the null characters that postgres can't store
    unzip -p "$file" | sed 's/\\u0000//g' | psql "postgresql://postgres:pass@localhost:$port_denormalized/postgres" -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done
