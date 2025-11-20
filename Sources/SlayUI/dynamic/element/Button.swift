
public struct Button<Label: View>: View {
    public var body:Label

    public init(
        @ViewBuilder label: () -> Label 
    ) {
        self.body = label()
    }
}