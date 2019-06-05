import java


predicate dangerousSetter(RefType paramType, Method setter) {
  exists(XMLElement query, XMLCharacters chars, string field, string param |
    query.hasName("select") and
    query.getAttributeValue("parameterType").regexpFind("[a-zA-Z0-9]+$", _, _) = param and
    chars = query.getACharactersSet() and
    chars.getCharacters().regexpFind("\\$\\{[a-zA-Z0-9]+\\}", _, _).substring(2, -1) = field and
    paramType.hasName(param) and
    setter.getDeclaringType() = paramType and
    setter.getName().toLowerCase() = "get" + field.toLowerCase()
  )
}


from XMLElement query, XMLCharacters chars, string field, string param, RefType paramType, Method setter
where query.hasName("select") and
    query.getAttributeValue("parameterType").regexpFind("[a-zA-Z0-9]+$", _, _) = param and
    chars = query.getACharactersSet() and
    chars.getCharacters().regexpFind("\\$\\{[a-zA-Z0-9]+\\}", _, _).substring(2, -1) = field and
    paramType.hasName(param) and
    setter.getDeclaringType() = paramType and
    setter.getName().toLowerCase() = "get" + field.toLowerCase()
select paramType, setter
