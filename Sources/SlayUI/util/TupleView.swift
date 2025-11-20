
public struct TupleView<T: Sendable>: View {
    public var value:T

    public var body: Never {
        fatalError("tried getting the body of a `TupleView`")
    }
}