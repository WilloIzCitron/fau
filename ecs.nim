import polymorph, fcore, strutils
export polymorph, fcore, strutils

var definitions {.compileTime.}: seq[tuple[name: string, body: NimNode]]

## Defines a system, with an extra vars block for variables. Body is built in launchFau.
macro sys*(name: static[string], componentTypes: openarray[typedesc], body: untyped): untyped =
  var varBody = newEmptyNode()
  for (index, st) in body.pairs:
    if st.kind == nnkCall and st[0].strVal == "vars":
      body.del(index)
      varBody = st[1]
      break

  definitions.add (name, body)

  result = quote do:
    defineSystem(`name`, `componentTypes`, defaultSystemOptions, `varBody`)

## Runs the body with the specified lowerCase type when this entity has this component
macro whenComp*(entity: EntityRef, t: typedesc, body: untyped) =
  let varName = t.repr.toLowerAscii.ident
  result = quote do:
    if `entity`.alive and `entity`.hasComponent `t`:
      let `varName` {.inject.} = `entity`.fetchComponent `t`
      `body`

macro launchFau*(title: string) =

  result = newStmtList().add quote do:
    makeEcs()
  
  for def in definitions:
    result.add newCall(
      ident("makeSystemBody"),
      newLit(def.name),
      def.body
    )
  
  result.add quote do:
    commitSystems("run")
    buildEvents()
    initFau(run, windowTitle = `title`)
  