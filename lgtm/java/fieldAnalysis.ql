import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph


predicate dangerousSetter(RefType paramType, Method setter) {
  exists(XMLElement query, XMLCharacters chars, string field, string param |
query.hasName("select")
and  query.getAttributeValue("parameterType").regexpFind("[a-zA-Z0-9]+$", _, _) = param
and query.getAChild().getACharactersSet().getCharacters().regexpFind("\\$\\{[a-zA-Z0-9]+\\}", _, _).regexpCapture("\\$\\{([a-zA-Z0-9]+)\\}", 1) = field
and    paramType.hasName(param)
and    setter.getDeclaringType() = paramType
and     setter.getName().toLowerCase() = "get" + field.toLowerCase()
  )
}

class MyBatiscfg extends DataFlow::Configuration {
  MyBatiscfg() { this = "MyBatis" }

  override predicate isSource(DataFlow::Node source) {
    any()
  }

  override predicate isSink(DataFlow::Node sink) {
  	exists (RefType paramType, Method setter, MethodAccess ma |
        dangerousSetter(paramType, setter) and
        ma.getMethod() = setter and
        sink.asExpr() = ma )
  }
}

/*
from MyBatiscfg cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select source, source, sink, "bad flow"
*/

from RefType paramType, Method setter
where dangerousSetter(paramType, setter)
select paramType, setter
