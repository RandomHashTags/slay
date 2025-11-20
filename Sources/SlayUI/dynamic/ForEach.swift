
public struct ForEach<Content: View>: View {
    public var body:Content

    public init(
        @ViewBuilder content: () -> Content 
    ) {
        self.body = content()
    }
}