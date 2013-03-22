#!/bin/bash
# http://www.h2database.com/html/advanced.html#using_recover_tool
db_dir=/data/gerrit2/db
java -cp h2-1.3.171.jar org.h2.tools.Recover -trace -dir $db_dir
java -cp h2-1.3.171.jar org.h2.tools.RunScript -url jdbc:h2:ReviewDB.new -script $db_dir/ReviewDB.h2.sql
