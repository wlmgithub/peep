
import pymysql

conn = pymysql.connect(host='<host>',
                       unix_socket='/tmp/mysql.sock', 
                       user='<user>', 
                       passwd='<pass>', 
                       db='<db>')
cur = conn.cursor()

cur.execute(<query>)
for r in cur:
    print r
cur.close()
conn.close()
exit(0)
