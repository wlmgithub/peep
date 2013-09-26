
import re

jiraidRegex = re.compile('(?:jira|ticket)(?:-id)?:\s*[-a-z0-9]*', re.IGNORECASE)


comment = '''
foobar

jira-iD: ios-123
jira: mod-12345
ticket: tkt-1234
TiCkET-iD:   TTT-98987
ticket-ID:yyy-222

Set search name to equal query in search container

Change-Id: I5b9815a269ee401a1f512b3ab98047d868ec9c92
Ticket-Id: TRENDS-1612

'''

#jira_id = jiraidRegex.search(comment).group()[8:].strip()
#print jira_id

#m  = jiraidRegex.search(comment).group()
#print m
#print re.sub(r'(?i)-id', '', m)[5:].strip()


#for m in  re.findall('(?:jira|ticket)(?:-id)?:\s*[-a-z0-9]*', comment, re.IGNORECASE):
for m in  re.findall(jiraidRegex, comment):
  print m, '|',
#  jira_id = re.sub(r'(?i)-id', '', m)[5:].strip()

#  m = re.sub(r'(?i)-id', '', m)
#  m = re.sub(r'(?i)ticket', 'jira', m)
# --or-
  m = re.sub(r'-id', '', m, flags=re.I)
  m = re.sub(r'ticket', 'jira', m, flags=re.I)

  jira_id = m[5:].strip()
  print jira_id

"""
$ python t_regex.py
jira-iD: ios-123 | ios-123
jira: mod-12345 | mod-12345
ticket: tkt-1234 | tkt-1234
TiCkET-iD:   TTT-98987 | TTT-98987
"""


