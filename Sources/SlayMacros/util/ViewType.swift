
import SlayKit
import SlayUI

enum ViewType {
    case staticEmpty(StaticEmptyView)
    case staticHStack(StaticHStack)
    case staticList(StaticList)
    case staticRectangle(StaticRectangle)
    case staticText(StaticText)
    case staticVStack(StaticVStack)
    case staticZStack(StaticZStack)
}

// MARK: Axis
extension ViewType {
    var axis: Axis {
        switch self {
        case .staticHStack: .horizontal
        default: .vertical
        }
    }
}

// MARK: Background color
extension ViewType {
    var backgroundColor: Color? {
        switch self {
        case .staticEmpty(let v): v.backgroundColor
        case .staticHStack(let v): v.backgroundColor
        case .staticList(let v): v.backgroundColor
        case .staticRectangle(let v): v.backgroundColor
        case .staticText(let v): v.backgroundColor
        case .staticVStack(let v): v.backgroundColor
        case .staticZStack(let v): v.backgroundColor
        }
    }
}

// MARK: Children
extension ViewType {
    var children: [ViewNode] {
        switch self {
        case .staticHStack(let v): v.data.map({ .init(type: $0.viewType) })
        case .staticList(let v): v.data.map({ .init(type: $0.viewType) })
        case .staticVStack(let v): v.data.map({ .init(type: $0.viewType) })
        case .staticZStack(let v): v.data.map({ .init(type: $0.viewType) })
        default: []
        }
    }
}

// MARK: Frame
extension ViewType {
    var frame: StaticRectangle {
        switch self {
        case .staticEmpty(let v): v.frame
        case .staticHStack(let v): v.frame
        case .staticList(let v): v.frame
        case .staticRectangle(let v): v.frame
        case .staticText(let v): v.frame
        case .staticVStack(let v): v.frame
        case .staticZStack(let v): v.frame
        }
    }
}

// MARK: Gap
extension ViewType {
    var gap: Float {
        switch self {
        case .staticEmpty: 0
        case .staticHStack: 8
        case .staticList: 8
        case .staticRectangle: 0
        case .staticText: 0
        case .staticVStack: 8
        case .staticZStack: 0
        }
    }
}

// MARK: Name
extension ViewType {
    var name: String {
        switch self {
        case .staticEmpty: "StaticEmptyView"
        case .staticHStack: "StaticHStack"
        case .staticList: "StaticList"
        case .staticRectangle: "StaticRectangle"
        case .staticText: "StaticText"
        case .staticVStack: "StaticVStack"
        case .staticZStack: "StaticZStack"
        }
    }
}

// MARK: StaticView extension
extension StaticView {
    var viewType: ViewType {
        if let v = self as? StaticRectangle {
            return .staticRectangle(v)
        }
        if let v = self as? StaticList {
            return .staticList(v)
        }
        if let v = self as? StaticHStack {
            return .staticHStack(v)
        }
        if let v = self as? StaticVStack {
            return .staticVStack(v)
        }
        if let v = self as? StaticZStack {
            return .staticZStack(v)
        }
        if let v = self as? StaticText {
            return .staticText(v)
        }
        if let v = self as? StaticEmptyView {
            return .staticEmpty(v)
        }
        fatalError("u forgor")
    }
}