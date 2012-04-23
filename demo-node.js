graphvizjs = require('./graphviz.opt.js').Module

var gv = graphvizjs.cwrap('graphvizjs','string',['string','string','string']);
// var gv = graphvizjs.graphvizjs;
console.log(gv('digraph g {}', 'dot', 'dot'))
