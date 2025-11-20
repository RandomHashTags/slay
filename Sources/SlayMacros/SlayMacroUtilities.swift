
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Append array
func appendArray(
    context: some MacroExpansionContext,
    array: ArrayElementListSyntax,
    into data: inout [any StaticView]
) {
    for element in array {
        guard let view = ViewMacro.parseView(context: context, expr: element.expression) else { continue }
        appendView(view, to: &data)
    }
}

// MARK: Append code block list
func appendCodeBlockList(
    context: some MacroExpansionContext,
    codeBlockList: CodeBlockItemListSyntax,
    into data: inout [any StaticView]
) {
    for element in codeBlockList {
        switch element.item {
        case .expr(let expr):
            guard let view = ViewMacro.parseView(context: context, expr: expr) else { continue }
            appendView(view, to: &data)
        default:
            break
        }
    }
}

// MARK: Append view
func appendView(
    _ viewType: ViewMacro.ViewType,
    to data: inout [any StaticView]
) {
    switch viewType {
    case .staticHStack(let v): data.append(v)
    case .staticList(let v): data.append(v)
    case .staticRectangle(let v): data.append(v)
    case .staticVStack(let v): data.append(v)
    case .staticZStack(let v): data.append(v)
    default:
        break
    }
}