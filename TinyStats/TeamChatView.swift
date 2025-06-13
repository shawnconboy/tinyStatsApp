import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let senderID: String
    let senderName: String
    let timestamp: Date
}

struct TeamChatView: View {
    let teamID: String
    @EnvironmentObject var auth: AuthViewModel
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""

    private var db: Firestore { Firestore.firestore() }

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            messageBubble(for: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last?.id {
                        withAnimation {
                            scrollProxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack {
                TextField("Type something...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Team Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadMessages)
    }

    private func sendMessage() {
        guard let uid = auth.user?.uid else { return }
        let name = auth.adminProfile?.name ?? auth.memberProfile?.name ?? "Unknown"

        let message = ChatMessage(
            text: newMessage,
            senderID: uid,
            senderName: name,
            timestamp: Date()
        )

        do {
            try db.collection("teams")
                .document(teamID)
                .collection("chatMessages")
                .addDocument(from: message)
            newMessage = ""
        } catch {
            print("❌ Failed to send message: \(error.localizedDescription)")
        }
    }

    private func loadMessages() {
        db.collection("teams")
            .document(teamID)
            .collection("chatMessages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error loading messages: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap {
                    try? $0.data(as: ChatMessage.self)
                }
            }
    }

    @ViewBuilder
    private func messageBubble(for msg: ChatMessage) -> some View {
        let isCurrentUser = msg.senderID == auth.user?.uid

        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(msg.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(msg.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray6))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(14)
                    .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)

                Text(msg.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
