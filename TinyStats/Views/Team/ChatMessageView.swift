import SwiftUI
import AVKit

struct ChatMessageView: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    let onDelete: (ChatMessage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.senderName)
                .font(.caption)
                .foregroundColor(.gray)

            Group {
                switch message.type {
                case "text":
                    Text(message.content)
                        .padding(10)
                        .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(10)

                case "image":
                    if let url = message.mediaURL, let imgURL = URL(string: url) {
                        AsyncImage(url: imgURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(10)
                            } else if phase.error != nil {
                                Text("Error loading image")
                            } else {
                                ProgressView()
                            }
                        }
                    }

                case "video":
                    if let url = message.mediaURL {
                        VideoPlayerView(url: url)
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                default:
                    Text("Unsupported message type.")
                }
            }
            .onLongPressGesture {
                if isCurrentUser {
                    onDelete(message)
                }
            }

            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
