{
    let enabledSettings = {}
    let validSettings = options.validSettings || {}
    let settingsId = null
    function v(a) {console.log(a); return a}
}

settings = at "settings" _ openblock __ head:setting tail:(__ ";" __ @(setting / settingsIdLine))* __ closeblock {
    return {
        [head.name]: head.value,
        ...(tail.reduce((p, c) => {
            p[c.name] = c.value
            return p
        }, {}))
    }
}

setting = name:word _ state:value {
    if(enabledSettings[name]) return error(`Found duplicate setting`)
    if(!validSettings[name]) return error(`Unknown setting \`${name}\``)
    if(validSettings[name] !== state.type) return error(`Invalid setting \`${name}\` is of type {${state.type}} when it should be {${validSettings[name]}}`)
    enabledSettings[name] = state.value
    return {
        name,
        value: state.value
    }
}

settingsIdLine = at _ t:type {
    if(settingsId) return error("Found duplicate id line in @settings")
    settingsId = t
}

value = v:(integer / boolean) {return v}
integer "integer" = digits:[0-9]+ { return { value: parseInt(digits.join(""), 10), type: 'integer' } }
boolean "boolean" = value:("yes" / "no") { return { value: value === 'yes', type: 'boolean'} }
word "a-z" = $[a-zA-Z]i+ {return text()}


type = $("Int" / "String" / "Boolean")
at = '@'
openblock = '{'
closeblock = '}'
_ "whitespace"
  = [ \t]+
__ "whitespace" = [ \t\n\r]*