import python
import semmle.python.security.TaintTracking
import semmle.python.web.Http
import semmle.python.security.strings.Basic
import Twisted
import Request

class TwistedResponse extends TaintSink {
    TwistedResponse() {
        exists(PythonFunctionValue func, string name, Return ret |
            isKnownRequestHandlerMethodName(name) and
            name = func.getName() and
            func = getTwistedRequestHandlerMethod(name) and
            this = func.getAReturnedNode()
        )
    }

    override predicate sinks(TaintKind kind) { kind instanceof ExternalStringKind }

    override string toString() { result = "Twisted response" }
}

/**
 * A sink of taint in the form of a "setter" method on a twisted request
 * object, which affects the properties of the subsequent response sent to this
 * request.
 */
class TwistedRequestSetter extends HttpResponseTaintSink {
    TwistedRequestSetter() {
        exists(CallNode call, ControlFlowNode node, string name |
            (
                name = "setHeader" or
                name = "addCookie" or
                name = "write"
            ) and
            any(TwistedRequest t).taints(node) and
            node = call.getFunction().(AttrNode).getObject(name) and
            this = call.getAnArg()
        )
    }

    override predicate sinks(TaintKind kind) { kind instanceof ExternalStringKind }

    override string toString() { result = "Twisted request setter" }
}
