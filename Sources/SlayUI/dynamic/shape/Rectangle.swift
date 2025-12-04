
public struct Rectangle: View {

    package var width:Int32?
    package var height:Int32?
    public var backgroundColor:Color?

    public init(
        width: Int32? = nil,
        height: Int32? = nil,
        backgroundColor: Color? = nil
    ) {
        self.width = width
        self.height = height
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        EmptyView() // TODO: fix
    }
}