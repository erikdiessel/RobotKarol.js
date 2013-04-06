current_bool = false
user_defined = {}
rules = [ # order is important
  #{
    #pattern: 
      #///
        #\b?wenn
        #\b(\c)+dann
        #\b(*)sonst
        #\b(*)\b
        #\*wenn(*)
      #///im
      #
    #interpreter: (condition, if_branch, else_branch) ->
      #current_bool = false
      #interprete(condition)
      #if (current_bool)
        #interprete(if_branch)
      #else
        #interprete(else_branch)
  #},
  #
  #{
    #pattern: /\b?Wahr\b(*)/im,
    #interpreter: ->
      #current_bool = true
  #},
  #
  #{ # defining own statements
    #pattern: /\b?Anweisung\b(\c)+\b(*)\b\*Anweisung/im,
    #interpreter: (name, body) ->
      #user_defined[name] = body
  #},
  
  {
    pattern: ///
      ^\s* # Match all preceeding whitespace, including linebreaks
      Schritt
      ([^]*) # Matches all following characters
    ///im,
    
    interpreter: ->
      @world.karolPosition.x += @world.karolDirection.x
      @world.karolPosition.y += @world.karolDirection.y
  }
#,
  #{ # user-defined statements, conditions
    #pattern: [/\b(\c)+(*)/gi],
    #interpreter: (name) ->
      #interprete(user_defined[name])
  #}
]

# executes the code (a string)
window.interpreter = (world) ->
  runtime =
    world: world
    current_bool: false
    user_defined: {}
  interprete = (code) ->
    unless (/^\s*$/m).test(code)
      for rule in rules
        if rule.pattern.test(code)
          bindings = rule.pattern.exec(code)
          following = bindings.pop()
          # apply function with *this* set to runtime
          rule.interpreter.apply(runtime, bindings.splice(1,bindings.length-1))
          interprete(following)
          return
        # no pattern matches => syntax error
        console.log("Syntax error at #{code.slice(0,50)}")
  return interprete

# constructor of the world
class window.World
  constructor: (length, width, height) ->
    @fields = []
    for x in [0..length]
      @fields[x] = []
      for y in [0..width]
        @fields[x][y] = new Field()
    # Karol is placed in the lower left corner
    @karolPosition = {x: 0, y: 0}
    # Karol faces upwards
    @karolDirection = {x: 0, y:1}

# constructor for the fields
Field = ->
  @stones_count = 0
  @mark_set = false