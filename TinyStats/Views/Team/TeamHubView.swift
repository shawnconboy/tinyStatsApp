import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TeamHubView: View {
    let teamID: String

    @State private var teamName: String = ""
    @State private var teamDescription: String = ""
    @State private var schedule: [TeamScheduleItem] = []
    @State private var selectedScheduleItem: TeamScheduleItem? = nil
    @State private var showGameDetailSheet: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main Header
                    Text("Team Hub")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)

                    // Team Info
                    VStack(spacing: 4) {
                        Text(teamName.isEmpty ? "Loading..." : teamName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(teamDescription)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    // Chat Button
                    NavigationLink(destination: TeamChatView(teamID: teamID)) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Open Team Chat")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Upcoming Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        if schedule.isEmpty {
                            Text("No upcoming events.")
                                .padding(.horizontal)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(schedule) { item in
                                let isUpcomingGame = item.type == "Game" && item.date >= Calendar.current.startOfDay(for: Date())
                                TeamScheduleTile(item: item)
                                    .padding(.horizontal)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if isUpcomingGame {
                                            selectedScheduleItem = item
                                            showGameDetailSheet = true
                                        }
                                    }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.bottom)
            }
            .onAppear {
                loadTeamData()
                loadSchedule()
            }
        }
        .sheet(isPresented: $showGameDetailSheet, onDismiss: { selectedScheduleItem = nil }) {
            if let item = selectedScheduleItem {
                GameDetailSheet(item: item)
            }
        }
    }

    private func loadTeamData() {
        let db = Firestore.firestore()
        db.collection("teams").document(teamID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                teamName = data["name"] as? String ?? "Team"
                teamDescription = data["description"] as? String ?? ""
                print("✅ Loaded team: \(teamName), \(teamDescription)")
            } else {
                print("❌ Failed to load team data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func loadSchedule() {
        let db = Firestore.firestore()
        db.collection("teams").document(teamID).collection("schedule")
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    print("📦 Found \(docs.count) schedule docs")
                    for doc in docs {
                        print("🔎 Raw schedule doc: \(doc.data())")
                    }
                    self.schedule = docs.compactMap { doc in
                        do {
                            return try doc.data(as: TeamScheduleItem.self)
                        } catch {
                            print("❌ Decode error: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    print("✅ Loaded \(self.schedule.count) valid schedule items")
                } else {
                    print("❌ Failed to load schedule: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }
}
