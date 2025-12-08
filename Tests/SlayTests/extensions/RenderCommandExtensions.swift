
import SlayKit

// MARK: Equatable
extension RenderCommand: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .rect(let lFrame, let lRadius, let lColor):
            guard case let .rect(rFrame, rRadius, rColor) = rhs else { return false }
            return lFrame == rFrame && lRadius == rRadius && lColor == rColor
        case .text(let lText, let lX, let lY, let lColor):
            guard case let .text(rText, rX, rY, rColor) = rhs else { return false }
            return lText == rText && lX == rX && lY == rY && lColor == rColor
        case .textVertices(let lVertices, let lColor):
            guard case let .textVertices(rVertices, rColor) = rhs else { return false }
            return lVertices == rVertices && lColor == rColor
        }
    }
}