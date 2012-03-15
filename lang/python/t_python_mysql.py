#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# releasenest1 under ~falcon/hostmon
#
# [liming@smfc-ail-02-sr1 hostmon]$ python get_live_version.py 
# 8fc80870
# [liming@smfc-ail-02-sr1 hostmon]$ pwd
# /home/falcon/hostmon
#
# connect to db
# get live version
dbhost = "smfc-aih-11-sr1.corpdc.twitter.com"
user = "rel_info_admin"
password = "<use_the_real_pwd_for_real>"
database = "release_info"
port = 3306

import MySQLdb as mdb
import sys

con = mdb.connect(host=dbhost, user=user, passwd=password, db=database, port=port)

if con: 
  cur = con.cursor()
  cur.execute("select `master_sha1` from release_change where `live` = true  and `app` = 'twitter'")

  rows = cur.fetchall()

  for row in rows:
      print row[0][0:8]
