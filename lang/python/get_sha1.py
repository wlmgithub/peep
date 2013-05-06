#
# http://stackoverflow.com/questions/552659/assigning-git-sha1s-without-git
#
"""
This is how Git calculates the SHA1 for a file (or, in Git terms, a "blob"):

sha1("blob " + filesize + "\0" + data)
So you can easily compute it yourself without having Git installed. Note that "\0" is the NULL-byte, not a two-character string.

For example, the hash of an empty file:

sha1("blob 0\0") = "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"

$ touch empty
$ git hash-object empty
e69de29bb2d1d6434b8b29ae775ad8c2e48c5391
Another example:

sha1("blob 7\0foobar\n") = "323fae03f4606ea9991df8befbb2fca795e648fa"

$ echo "foobar" > foo.txt
$ git hash-object foo.txt 
323fae03f4606ea9991df8befbb2fca795e648fa
Here is a Python implementation:

from hashlib import sha1
def githash(data):
    s = sha1()
    s.update("blob %u\0" % len(data))
    s.update(data)
    return s.hexdigest()

"""

from hashlib import sha1
def githash(data):
  s = sha1()
  s.update("blob %u\0" % len(data))
  s.update(data)
  return s.hexdigest()

print githash("")
print githash("foobar\n")
