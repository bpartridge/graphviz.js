require('./graphviz.js')

var gv = Module.cwrap('graphvizjs','string',['string','string','string']);
console.log(gv('digraph g {}', 'dot', 'dot'))
