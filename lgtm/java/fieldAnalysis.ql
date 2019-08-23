/**
 * @name User-controlled data use in myBatis set call
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
private import semmle.code.java.dataflow.DataFlow::DataFlow

// Parse Xbatis XMLs to get the SQL text for each id.
/**
 * A `<mapper..>` element in an Xbatis XML file.
 */
class MapperXMLElement extends XMLElement {
  MapperXMLElement() { hasName("mapper") }

  /** Gets the `namespace` in `<mapper namespace="...">` */
  RefType getNamespaceRefType() { result.getQualifiedName() = getAttributeValue("namespace") }

  /** Gets a `<select>` element of this `<mapper>`. */
  SelectXMLElement getASelectXMLElement() { result = getAChild() }
}

/**
 * A `<select..>` element in an Xbatis XML file.
 */
class SelectXMLElement extends XMLElement {
  SelectXMLElement() { hasName("select") }

  /** Gets the `parameterType` in `<select parameterType="...">` */
  RefType getParameterType() { result.getQualifiedName() = getAttributeValue("parameterType") }

  /** Gets the `id` value in `<select id="...">` */
  string getId() { result = getAttributeValue("id") }

  /** Gets a part of the query string i.e. the "SQL text". */
  string getAQueryString() { result = getAChild+().getACharactersSet().getCharacters() }
}

/**
 * A Java method which executes an SQL query when called.
 */
abstract class MyBatisSelectMethod extends Method {
  /**
   * A field which is used in an unsafe way in the query.
   */
  abstract Field getAnUnsafeField(int argIndex);
}

// Third, when analyzing possible database access methods, find the corresponding SQL string with the corresponding id of the method.
// Fourth, identify the fields in the string referenced by $.
/**
 * Find a Java method that corresponds to a `<select>` in a Xbatis XML file.
 */
class MyBatisSelectMethodXML extends MyBatisSelectMethod {
  /** The corresponding `<select>` in the XML file. */
  SelectXMLElement selectElement;

  MyBatisSelectMethodXML() {
    exists(MapperXMLElement mapper |
      // Find a `<select>` element in a `<mapper>` element
      mapper.getASelectXMLElement() = selectElement and
      // This method is declared on the type specified in namespace attribute in `<mapper namespace="..">`.
      this.getDeclaringType() = mapper.getNamespaceRefType() and
      // This method has the name specified in id attribute in `<select id="...">`.
      this.getName() = selectElement.getId()
    )
  }

  /**
   * Returns an "unsafe" field used in the `<select..>` which is referenced by `$`.
   */
  override Field getAnUnsafeField(int argIndex) {
    // The field we look for is declared in the `parameterType` attribute in `<select parameterType="...">`.
    result.getDeclaringType().getASubtype*() = selectElement.getParameterType() and
    (
      // Use regexp to find `${...}`, and match the name to the name of the field
      result.getName() = selectElement
            .getAQueryString()
            .regexpFind("\\$\\{[a-zA-Z0-9.]+\\}", _, _)
            .regexpCapture("\\$\\{([a-zA-Z0-9]+).*\\}", 1)
      or
      // Use regexp to find `$...$`, and match the name to the name of the field
      result.getName() = selectElement
            .getAQueryString()
            .regexpFind("\\$[a-zA-Z0-9.]+\\$", _, _)
            .regexpCapture("\\$([a-zA-Z0-9]+).*\\$", 1)
    ) and
    (
      // There is a getter method that returns the value without modification
      exists(GetterMethod getterMethod |
        getterMethod.getField() = result and
        getterMethod.getDeclaringType() = result.getDeclaringType()
      )
      or
      // no getter exists, direct field access
      not exists(Method getterMethod |
        getterMethod.getName().toLowerCase() = "get" + result.getName().toLowerCase()
      )
    ) and
    // It's always the first and only argument to the select method
    argIndex = 0
  }
}

/** An `@SelectProvider` annotation. */
class SelectProviderAnnotation extends Annotation {
  SelectProviderAnnotation() { getType().hasName("SelectProvider") }

  /**
   * Gets the Type specified in the "type" property of the annotation.
   */
  Type getSqlProviderType() {
    result = getValue("type").(TypeLiteral).getTypeName().(TypeAccess).getType()
  }
}

/** An `@Param` annotation. */
class ParamAnnotation extends Annotation {
  ParamAnnotation() { getType().hasName("Param") }
}

/** A method which is involved in dynamically creating a query. */
class DynamicQuery extends MethodAccess {
  DynamicQuery() {
    getMethod().getName() = any(string s | s = "SELECT" or s = "FROM" or s = "WHERE")
  }
}

/**
 * A method with an `@SelectProvider` annotation.
 */
class MyBatisSelectProviderMethod extends MyBatisSelectMethod {
  SelectProviderAnnotation annotation;

  MyBatisSelectProviderMethod() { annotation = getAnAnnotation() }

  /**
   * Gets the @Param("name") value for the given parameter index.
   */
  string getSQLParamName(int paramIndex) {
    result = getParameter(paramIndex)
          .getAnAnnotation()
          .(ParamAnnotation)
          .getAValue()
          .(CompileTimeConstantExpr)
          .getStringValue()
  }

  override Field getAnUnsafeField(int argIndex) {
    /*
     * Find this pattern:
     * ```
     * public SQL query(Map<String, Object> params) {
     *   UserObject userObject = (UserObject) params.get("userObject");
     *   return new SQL() {
     *     {
     *       SELECT("a.*");
     *       FROM("A");
     *       WHERE("a.a = " + userObject.getA());
     *   };
     * }
     * ```
     */
    exists(
      Method queryMethod, MethodAccess getParamCall, MethodAccess getField,
      DynamicQuery dynamicQueryCall
    |
      // Find the "query "method declared on the "type" specified in the annotation
      queryMethod.hasName("query") and
      queryMethod.getDeclaringType() = annotation.getSqlProviderType() and
      // Identify a Map.get(<paramName>) call
      localFlow(parameterNode(queryMethod.getParameter(0)), exprNode(getParamCall.getQualifier())) and
      // <paramName> matches @Param field
      getParamCall.getArgument(0).(CompileTimeConstantExpr).getStringValue() = getSQLParamName(argIndex) and
      exists(LocalVariableDecl v |
        // Identify a local variable to which the parameter is assigned to
        v.getInitializer() = any(CastExpr ce | ce.getExpr() = getParamCall) and
        // Identify a getter call
        v.getAnAccess() = getField.getQualifier() and
        // The declaring type of the field must be a super type of the local variable
        result.getDeclaringType() = v.getType().(RefType).getASupertype*()
      ) and
      // Identify the name of the field being set, based on the name of the getter
      "get" + result.getName().toLowerCase() = getField.getMethod().getName().toLowerCase() and
      // Determine whether the result of the field getter ends up in a SELECT() or FROM() or WHERE()
      TaintTracking::localTaint(exprNode(getField), exprNode(dynamicQueryCall.getAnArgument()))
    )
  }
}

/** A (assumed) sanitizing method. */
class SqlSanitizer extends MethodAccess {
  SqlSanitizer() { getMethod().hasName("trimSql") }
}

/** Holds if field `f` is on `instance` is set to `value`. */
private predicate isSetField(Expr instance, InstanceField f, Expr value) {
  // Call to setter method
  exists(
    AssignExpr ae, FieldAccess fa, Expr localValue, Call call, Callable setterCallable, Parameter p
  |
    setterCallable = call.getCallee() and
    fa = f.getAnAccess() and
    fa = ae.getDest().getProperExpr() and
    fa.isOwnFieldAccess() and
    localValue = ae.getSource() and
    localValue.getEnclosingCallable() = setterCallable and
    DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(localValue)) and
    value = call.getArgument(p.getPosition())
  |
    call instanceof ClassInstanceExpr and instance = call
    or
    call instanceof MethodAccess and instance = call.getQualifier()
  )
  or
  // Direct field assignment
  exists(AssignExpr ae, FieldAccess fa |
    fa = f.getAnAccess() and
    fa = ae.getDest().getProperExpr() and
    not fa.isOwnFieldAccess() and
    value = ae.getSource() and
    instance = fa.getQualifier()
  )
}

/**
 * This is a helper dataflow for tracking from untrusted input, to setters of "unsafe" fields.
 */
class UntrustedDataToSetterConfig extends TaintTracking::Configuration2 {
  UntrustedDataToSetterConfig() { this = "untrusteddatatosetter" }

  override predicate isSource(DataFlow2::Node source) {
    // Untrusted input
    exists(Parameter p |
      p.getAnAnnotation().getType().hasName("Param") and
      source.asParameter() = p
    ) or
    source.asParameter().getCallable().getAnAnnotation().getType().hasName("RequestMapping")
  }

  override predicate isSink(DataFlow2::Node sink) {
    exists(MyBatisSelectMethod selectMethod |
      isSetField(_, selectMethod.getAnUnsafeField(_), sink.asExpr())
    )
  }

  override predicate isSanitizer(DataFlow::Node node) {
    node.asExpr() instanceof SqlSanitizer
  }
}

/**
 * This is a field sensitive data flow analysis, for tracking whether an unsafe field in a MyBatis
 * parameter type class can contain untrusted data when passed as an argument to a MyBatis "select"
 * method.
 */
class MyBatiscfg extends DataFlow::Configuration {
  // The select method that we're using as the sink
  MyBatisSelectMethod selectMethod;

  // The unsafe field that this configuration is tracking
  Field unsafeField;

  // The index of the argument to the select method
  int argIndex;

  MyBatiscfg() {
    this = "MyBatis-" + unsafeField.getName() + "-" + selectMethod.getQualifiedName() + "-" + argIndex and
    unsafeField = selectMethod.getAnUnsafeField(argIndex)
  }

  /** Gets the unsafe field being tracked. */
  Field getUnsafeField() { result = unsafeField }

  override predicate isSource(DataFlow::Node source) {
    // An untrusted @Param whose type contains the unsafe field
    exists(Parameter p |
      p.getAnAnnotation().getType().hasName("Param") and
      source.asParameter() = p and
      unsafeField.getDeclaringType() = p.getType().(RefType).getASupertype*()
    )
    or
    // An untrusted @RequestMapping parameter whose type contains the unsafe field
    source.asParameter().getCallable().getAnAnnotation().getType().hasName("RequestMapping") and
    unsafeField.getDeclaringType() = source.getType().(RefType).getASupertype*()
    or
    // An instance of the "parameterType" class which is tainted by a setter call.
    exists(UntrustedDataToSetterConfig cfg, Expr setValue |
      cfg.hasFlow(_, DataFlow2::exprNode(setValue)) and
      isSetField(source.asExpr(), unsafeField, setValue)
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    // Sink is an argument to a call to the select method.
    exists(MethodAccess ma |
      ma.getCallee() = selectMethod and
      ma.getArgument(argIndex) = sink.asExpr()
    )
  }

  override predicate isBarrier(DataFlow::Node node) {
    /*
     * Stop tracking if we see a method call, where the contents of that method call may override
     * the tracked field.
     */
    exists(MethodAccess ma, int index, Expr access |
      ma.getArgument(index) = node.asExpr() and
      DataFlow::localFlow(DataFlow::parameterNode(ma.getMethod().getParameter(index)),
        DataFlow::exprNode(access)) and
      isSetField(access, unsafeField, _)
    )
  }

  override predicate isBarrierEdge(DataFlow::Node start, DataFlow::Node node) {
    // Stop taint tracking if the field is over written by a call to `set<FieldName>`.
    isSetField(node.asExpr(), unsafeField, _)
  }
}

from MyBatiscfg cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink, source, sink,
  "Field " + cfg.getUnsafeField() + " contains untrusted data, and is used unescaped in a query."
