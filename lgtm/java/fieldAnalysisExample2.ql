/**
 * @name User-controlled data use in myMatis set call
 * @description Field Analysis example
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id java/tainted-mybatis-field-taint
 * @tags security
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

predicate dangerousSetter(RefType paramType, Method setter) {
  exists(XMLElement query, XMLCharacters chars, string field, string param |
    query.hasName("select") and
    query.getAttributeValue("parameterType").regexpFind("[a-zA-Z0-9]+$", _, _) = param and
    query
        .getAChild()
        .getACharactersSet()
        .getCharacters()
        .regexpFind("\\$\\{[a-zA-Z0-9]+\\}", _, _)
        .regexpCapture("\\$\\{([a-zA-Z0-9]+)\\}", 1) = field and
    paramType.hasName(param) and
    setter.getDeclaringType() = paramType and
    setter.getName().toLowerCase() = "set" + field.toLowerCase()
  )
}

predicate myBatisSink(MethodAccess ma) {
  exists(Method m, Method n |
    m.getName() = "query" and
    m.getDeclaringType().getName() = "UserInfoDAO" and
    n.overrides*(m) and
    ma.getMethod() = n
  )
}

class MyBatiscfg extends DataFlow::Configuration {
  MyBatiscfg() { this = "MyBatis" }

  override predicate isSource(DataFlow::Node source) {
    exists(Parameter p |
      p.getAnAnnotation().getType().hasName("Param") and
      source.asParameter() = p
    )
  }

  override predicate isSink(DataFlow::Node sink) {
  	exists(MethodAccess ma |
  	myBatisSink(ma) and
  	ma.getAnArgument() = sink.asExpr())
  }
  
  override predicate isAdditionalFlowStep(DataFlow::Node start, DataFlow::Node stop) {
    exists(RefType paramType, Method setter, MethodAccess ma |
      dangerousSetter(paramType, setter) and
      ma.getMethod() = setter and
      start.asExpr() = ma.getAnArgument() and
      stop.asExpr() = ma.getQualifier()
    )
  }
}

from MyBatiscfg cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select source, source, sink, "Flow through bad setter into Query execute"


