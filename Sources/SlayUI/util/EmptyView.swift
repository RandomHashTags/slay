
public struct EmptyView: View {
    public var body: Never {
        fatalError("tried getting body of an `EmptyView`")
    }
}

extension Never: View {
    public var body: Never {
        fatalError("tried getting body of `Never`")
    }
}