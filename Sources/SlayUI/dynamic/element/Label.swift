
public struct Label<Text: View, Icon: View>: View {
    public var icon:Icon
    public var text:Text

    public init(
        @ViewBuilder text: () -> Text,
        @ViewBuilder icon: () -> Icon
    ) {
        self.text = text()
        self.icon = icon()
    }

    public var body: some View {
        HStack {
            icon
            text
        }
    }
}