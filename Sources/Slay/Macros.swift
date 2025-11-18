
@attached(member, names: arbitrary)
public macro View(
    supportedStaticDimensions: [(width: Int32, height: Int32)] = [(1920, 1080)]
) = #externalMacro(module: "SlayMacros", type: "ViewMacro")