
import SlayKit

@attached(member, names: arbitrary)
public macro View(
    supportedStaticDimensions: [(width: Int32, height: Int32)] = slaySupportedStaticDimensions
) = #externalMacro(module: "SlayMacros", type: "ViewMacro")