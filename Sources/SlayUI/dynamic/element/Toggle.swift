
public struct Toggle<Label: View>: View {
    public var label:Label
    public var isOn:Bool

    public init(
        @ViewBuilder label: () -> Label,
        isOn: Bool
    ) {
        self.label = label()
        self.isOn = isOn
    }

    public var body: some View {
        HStack {
            label
        }
    }
}