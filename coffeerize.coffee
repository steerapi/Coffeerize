fs = require("fs")
sys = require("sys")
exec = require("child_process").exec
util  = require('util')
spawn = require('child_process').spawn

exec_coffee_cb = (error, stdout, stderr) ->
  files = stdout.split("\n")
  i = files.length - 1
  while i >= 0
    file = files[i]
    if file != "" and file.indexOf("node_modules")==-1
      split = file.split(".")
      filename = split[0];
      ext = split[split.length-1];
      cmd = "js2coffee"
      content = fs.readFileSync "#{filename}.js"
      julia = spawn(cmd, [])
      do (filename)->
        julia.stdout.on 'data', (data)->
          #console.log("{"+data+"}")
          name = "#{filename}.coffee"
          fs.writeFileSync name, data
          console.log "complied: " + name
          exec "rm #{filename}.js", (error, stdout, stderr) ->
            console.log stderr if error
      julia.stdin.write(content)
      julia.stdin.end()
    i--
  #process.exit(1);
  return
  
exec_coffeerize_cb = (error, stdout, stderr) ->
  exec "find coffeerized_#{folder} -name \"*.js\"", exec_coffee_cb
  return

exec_rm_cb = (error, stdout, stderr) ->
  exec "cp -r #{folder} coffeerized_#{folder}", exec_coffeerize_cb
  return

if process.argv.length < 3
  console.log """
      Usage: coffee coffeerize.coffee [folder]
  """
  process.exit(1);

folder = process.argv[2]

exec "rm -r coffeerized_#{folder}", exec_rm_cb