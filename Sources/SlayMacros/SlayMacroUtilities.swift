
import SlayKit
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Append array
func appendArray(
    context: some MacroExpansionContext,
    array: ArrayElementListSyntax,
    fontAtlas: borrowing FontAtlas,
    into data: inout [any StaticView]
) {
    for element in array {
        guard let view = ViewType.parse(context: context, expr: element.expression, fontAtlas: fontAtlas) else { continue }
        appendView(view, to: &data)
    }
}

// MARK: Append code block list
func appendCodeBlockList(
    context: some MacroExpansionContext,
    codeBlockList: CodeBlockItemListSyntax,
    fontAtlas: borrowing FontAtlas,
    into data: inout [any StaticView]
) {
    for element in codeBlockList {
        switch element.item {
        case .expr(let expr):
            guard let view = ViewType.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { continue }
            appendView(view, to: &data)
        default:
            break
        }
    }
}

// MARK: Append view
func appendView(
    _ viewType: ViewType,
    to data: inout [any StaticView]
) {
    switch viewType {
    case .staticEmpty(let v): data.append(v)
    case .staticHStack(let v): data.append(v)
    case .staticList(let v): data.append(v)
    case .staticRectangle(let v): data.append(v)
    case .staticText(let v): data.append(v)
    case .staticVStack(let v): data.append(v)
    case .staticZStack(let v): data.append(v)
    }
}