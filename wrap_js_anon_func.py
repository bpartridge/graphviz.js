#!/usr/bin/python

import sys

fname = sys.argv[1]
ending = '''
Module['_graphvizjs'] = _graphvizjs;
this['graphvizjs'] = Module.cwrap('graphvizjs', 'string', ['string','string','string']);
'''
with file(fname, 'r') as orig: data = orig.read()
with file(fname, 'w') as mod: mod.write("(function() {" + data + ending + "})()")
