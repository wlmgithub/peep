#
# joelonsoftware.com/articles/Unicode.html
#
import codecs, sys

#sys.stdout = codecs.lookup('iso8859-1')[-1](sys.stdout)

#sys.stdout = codecs.lookup('utf-8')[-1](sys.stdout)

char = u"\N{LATIN SMALL LETTER A WITH DIAERESIS}"

print char
