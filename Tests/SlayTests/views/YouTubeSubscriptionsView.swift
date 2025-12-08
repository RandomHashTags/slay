
import Slay
import SlayKit
import SlayUI

@View(
    renderInvisibleItems: true,
    renderTextAsRectangles: true
)
struct YouTubeSubscriptionsView: View {
    var body: some View {
        VStack {
            HStack { // subscribed channels
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(255, 255, 255, 255))
            }
            HStack { // filters
                Text("All")
                Text("Today")
                Text("Videos")
                Text("Shorts")
                Text("Live")
                Text("Podcasts")
            }
            List { // content
                Text("Shorts")
                HStack {
                    Rectangle(width: 150, height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                    Rectangle(width: 150, height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                    Rectangle(width: 150, height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                }
                // videos
                Rectangle(height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(height: 200, backgroundColor: .rgba(255, 255, 255, 255))
                Rectangle(height: 200, backgroundColor: .rgba(255, 255, 255, 255))
            }
        }
    }
}