import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI
import AVKit

struct ChatMessage: Identifiable {
    var id: String
    var content: String
    var senderName: String
    var senderID: String
    var timestamp: Date
    var type: String
    var mediaURL: String?
}

struct TeamChatView: View {
    let teamID: String

    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var listener: ListenerRegistration?
    
    // Media handling temporarily disabled
    // @State private var mediaItem: PhotosPickerItem?
    // @State private var mediaData: Data?
    // @State private var mediaType: String = "image"

    var body: some View {
        VStack {
            Text("Team Chat")
                .font(.largeTitle.bold())
                .padding(.top)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            ChatMessageView(
                                message: msg,
                                isCurrentUser: msg.senderID == Auth.auth().currentUser?.uid,
                                onDelete: { tryDelete($0) }
                            )
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let lastID = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Media picker temporarily disabled
                // PhotosPicker(selection: $mediaItem, matching: .any(of: [.images])) {
                //     Image(systemName: "paperclip")
                //         .font(.title2)
                // }

                Button("Send") {
                    if !newMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                        sendTextMessage()
                    }
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()

            // Upload indicator temporarily removed
            // if mediaData != nil {
            //     ProgressView("Uploading media...")
            // }
        }
        // .onChange(of: mediaItem, perform: { _ in })
        .onAppear {
            fetchMessages()
        }
        .onDisappear {
            listener?.remove()
        }
    }

    func fetchMessages() {
        let db = Firestore.firestore()
        listener = db.collection("teams").document(teamID).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    guard let content = data["content"] as? String,
                          let senderName = data["senderName"] as? String,
                          let senderID = data["senderID"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let type = data["type"] as? String else { return nil }

                    return ChatMessage(
                        id: doc.documentID,
                        content: content,
                        senderName: senderName,
                        senderID: senderID,
                        timestamp: timestamp.dateValue(),
                        type: type,
                        mediaURL: data["mediaURL"] as? String
                    )
                }
            }
    }

    func sendTextMessage() {
        guard let currentUser = Auth.auth().currentUser else { return }

        let db = Firestore.firestore()
        let newDoc = db.collection("teams").document(teamID).collection("messages").document()

        let messageData: [String: Any] = [
            "content": newMessage,
            "senderName": currentUser.email ?? "Unknown",
            "senderID": currentUser.uid,
            "timestamp": FieldValue.serverTimestamp(),
            "type": "text"
        ]

        newDoc.setData(messageData)
        newMessage = ""
    }

    // Media upload temporarily disabled
    // func handleMediaUpload() { ... }

    func tryDelete(_ message: ChatMessage) {
        guard message.senderID == Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("teams").document(teamID).collection("messages").document(message.id).delete()
    }
}

struct VideoPlayerView: View {
    let url: String

    var body: some View {
        if let videoURL = URL(string: url) {
            VideoPlayer(player: AVPlayer(url: videoURL))
        } else {
            Text("Invalid video")
        }
    }
}
