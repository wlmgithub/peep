#!/usr/bin/python

import MySQLdb
import simplejson as json
import optparse
import os
import subprocess
import sys
from foobar import util

BASE_PATH = '/data/git'
BASE_URL = 'https://git.foobar.biz'
JIRA_URL = 'http://jira.local.foobar.com/browse/%s'
PASSWD_PATH = '/etc/twkeys/apache/reviewboard/db_passwd'

reviewboard_passwd = open(PASSWD_PATH).read().strip()

conn = None

def add_to_reviewboard(repo, config={}):
  if 'master' in config:
    name = '%s:%s' % (config['master'], config['name'])
    repo_dir = '%s/%s/%s.git' % (BASE_PATH, config.get('master', '.'), repo)
    repo_url = '%s/%s/%s' % (BASE_URL, config.get('master', '.'), repo)
  else:
    name = config['name']
    repo_dir = '%s/%s.git' % (BASE_PATH, repo)
    repo_url = '%s/%s' % (BASE_URL, repo)
  sql = ('select id,path,bug_tracker from scmtools_repository '
         'where name="%s"' % name)
  conn.query(sql)
  sql = None
  data = conn.store_result()
  if data.num_rows() > 1:
    print 'Repo %s has too many reviewboard entries!' % repo
    return
  if data.num_rows() < 1:
    sql = ('insert into scmtools_repository '
           '(name, path, mirror_path, raw_file_url, username, password, '
           ' bug_tracker, encoding, tool_id, visible, public) '
           'values ("%s", "%s", "%s", "", "", "", "%s", "", 5, 1, 1)' %
           (name, repo_dir, repo_url, JIRA_URL))
  else:
    rows = [x for x in data.fetch_row(data.num_rows())]
    if (not [x for x in rows if x[1] != repo_dir] and
        not [x for x in rows if x[2] != JIRA_URL]):
      return
    sql = ('update scmtools_repository '
           'set name="%s",path="%s",tool_id=5,visible=1,bug_tracker="%s" '
           'where id=%s' %
           (name, repo_dir, JIRA_URL, rows[0][0]))
  if sql:
    conn.query(sql)
    conn.commit()

def verify_and_create(repo, config={}):
  cmd = """
set -e
if [ ! -d "%(base_path)s/%(master)s/%(repo)s.git" ] ; then
  mkdir -p "%(base_path)s/%(master)s/%(repo)s.git"
  cd "%(base_path)s/%(master)s/%(repo)s.git"
  git --bare init
fi
cd "%(base_path)s/%(master)s/%(repo)s.git"
if [ "%(protect_master)s" != "0" ] ; then
  if ! git config --get receive.denyNonFastForwards | grep true ; then
    git config receive.denyNonFastForwards true
  fi
fi
""" % {
        'base_path': BASE_PATH,
        'repo': repo,
        'master': config.get('master', '.'),
        'protect_master': config.get('protect_master', '0')
        }
  p = subprocess.Popen(cmd, shell=True)
  p.communicate()
  p.wait()
  # Catch errors!

  hook_dir = '%s/%s/%s.git/hooks' % (BASE_PATH, config.get('master', '.'), repo)
  hooks = config.get('hooks', {})
  expected_hooks = set(hooks.iterkeys())
  found_hooks = set(os.listdir(hook_dir))
  for hook in found_hooks.difference(expected_hooks):
    os.unlink('%s/%s' % (hook_dir, hook))
  for hook in expected_hooks.intersection(found_hooks):
    try:
      l = os.readlink('%s/%s' % (hook_dir, hook))
      if l == '%s/.conf/hooks/%s' % (BASE_PATH, hooks[hook]):
        continue
    except OSError:
      pass
    #os.unlink('%s/%s' % (hook_dir, hook))
    found_hooks.remove(hook)
  for hook in expected_hooks.difference(found_hooks):
    os.symlink('%s/.conf/hooks/%s' % (BASE_PATH, hooks[hook]),
               '%s/%s' % (hook_dir, hook))


def verify_cgitrc(repos):
  output = []
  for repo in sorted(repo_list, lambda x,y: cmp(x['name'], y['name'])):
    if 'master' in repo:
      name = '%s:%s' % (repo['master'], repo['name'])
    else:
      name = repo['name']

    text = """
repo.url=%(repo)s
repo.name=%(repo)s
repo.desc=%(description)s
repo.path=%(repo_path)s
repo.owner=foobar, Inc.
repo.defbranch=master
repo.snapshots=tar.bz2
repo.clone-url=https://git.foobar.biz/%(repo)s
""" % {
        'repo': name,
        'description': repo.get('description', 'Unknown'),
        'repo_path': '%s/%s/%s.git' % (BASE_PATH, repo.get('master', '.'),
                                       repo.get('name'))}
    output.append(text)
  expected = ''.join(output)

  try:
    current = open('%s/.conf/cgitrc' % BASE_PATH, 'r').read()
  except IOError:
    current = ''
  if current != expected:
    open('%s/.conf/cgitrc' % BASE_PATH, 'w').write(expected)


# Connect to the reviewboard backend.. We have to do this regardless.
conn = MySQLdb.connect(host='smfc-aih-11-sr1.corpdc.foobar.com',
                       user='reviewbrd_admin',
                       passwd=reviewboard_passwd,
                       db='reviewboard')

contents = open('%s/.conf/git_config' % BASE_PATH, 'r').read()
repo_list = json.loads(contents)
for repo in sorted(repo_list, lambda x,y: cmp(x['name'], y['name'])):
  verify_and_create(repo['name'], repo)
  add_to_reviewboard(repo['name'], repo)
verify_cgitrc(repo_list)
