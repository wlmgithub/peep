#
# http://stackoverflow.com/questions/6866600/yaml-parsing-and-python
# 

import yaml
import sys

f = open('tree.yaml')
# use safe_load instead load
dataMap = yaml.safe_load(f)
f.close()

print dataMap
print dataMap['treeroot']['branch1']['branch1-1']['name']
#sys.exit(0)

f = open('newtree.yaml', "w")
yaml.dump(dataMap, f)
f.close()
