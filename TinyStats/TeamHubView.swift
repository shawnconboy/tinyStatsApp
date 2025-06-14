import SwiftUI
import Firebase
import FirebaseFirestore

struct TeamHubView: View {
    let team: Team
    // Do NOT use 'private' or 'fileprivate' here!
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel: TeamHubViewModel
    @State private var showEditEvent: Bool = false
    @State private var selectedEvent: Event? = nil
    @State private var showAddEvent: Bool = false
    @State private var isPending: Bool = false

    init(team: Team) {
        self.team = team
        _viewModel = StateObject(wrappedValue: TeamHubViewModel(team: team))
    }

    var body: some View {
        VStack(spacing: 24) {
            if isPending {
                PendingApprovalView()
            } else if (auth.user != nil && auth.memberProfile == nil && auth.adminProfile == nil) {
                VStack {
                    Spacer()
                    ProgressView("Loading profile...")
                    Spacer()
                }
            } else {
                // Header
                Text("Welcome to the Team Hub")
                    .font(.largeTitle.bold())

                // Subheader
                Text("Here you'll find your team schedule, chat, and updates.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // Team Name
                Text(team.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)

                // Team Chat Button
                NavigationLink(destination: TeamChatView(teamID: team.id)) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.title2)
                        Text("Team Chat")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                // EVENTS SECTION
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Upcoming")
                            .font(.title3.bold())
                        Spacer()
                        // Allow admin, developer, and coach to add events
                        if let role = auth.adminProfile?.role, role == "admin" || role == "developer" || role == "coach" {
                            Button(action: { showAddEvent = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .accessibilityLabel("Add Event")
                        }
                    }
                    .padding(.leading, 4)

                    // Scrollable event cards, fixed height (about 3 cards)
                    GeometryReader { geo in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.events) { event in
                                    // Allow admin, developer, and coach to tap to edit events
                                    if let role = auth.adminProfile?.role, role == "admin" || role == "developer" || role == "coach" {
                                        Button(action: {
                                            selectedEvent = event
                                        }) {
                                            EventCard(event: event)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        EventCard(event: event)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(height: min(geo.size.height, 3 * 92))
                    }
                    .frame(height: 3 * 92)
                }
                .padding(.top, 8)

                Spacer()
            }
        }
        .padding()
        .navigationTitle("Team Hub")
        .navigationBarTitleDisplayMode(.inline)
        // Only admin/dev/coach can open edit event sheet
        .sheet(item: $selectedEvent, onDismiss: { viewModel.fetchEvents() }) { event in
            if let role = auth.adminProfile?.role, role == "admin" || role == "developer" || role == "coach" {
                EditEventView(
                    event: event,
                    teamID: team.id,
                    members: viewModel.members,
                    onSave: { viewModel.fetchEvents() },
                    onDelete: { viewModel.fetchEvents() }
                )
            }
        }
        .sheet(isPresented: $showAddEvent, onDismiss: { viewModel.fetchEvents() }) {
            AddEventView(
                teamID: team.id,
                members: viewModel.members,
                onAdd: { viewModel.fetchEvents(); showAddEvent = false }
            )
        }
        .onAppear {
            checkPendingStatus()
        }
    }

    // Check if the current member is pending approval
    private func checkPendingStatus() {
        // Do NOT use .wrappedValue or any property wrapper here!
        guard let user = auth.user else {
            isPending = false
            return
        }
        let db = Firestore.firestore()
        db.collection("joinRequests")
            .whereField("uid", isEqualTo: user.uid)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, _ in
                if let docs = snapshot?.documents, !docs.isEmpty {
                    isPending = true
                } else {
                    isPending = false
                }
            }
    }
}

// MARK: - PendingApprovalView

private struct PendingApprovalView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hourglass")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Your request to join this team is pending approval.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Once an admin approves your request, you'll have full access to your team's hub, schedule, and chat.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}

// MARK: - EventCard

private struct EventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.eventDate, formatter: DateFormatter.eventCardDay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(event.eventDate, formatter: DateFormatter.eventCardTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            // Use event.title or fallback to "TeamA vs TeamB"
            Text(event.title.isEmpty
                 ? "\(event.teamAName) vs \(event.teamBName)"
                 : event.title)
                .font(.headline)
                .foregroundColor(.primary)
            if !event.location.isEmpty {
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let snack = event.snackVolunteerName, !snack.isEmpty {
                HStack(spacing: 4) {
                    Text("🧁 Snack:")
                    Text(snack)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            if !event.note.isEmpty {
                HStack(spacing: 4) {
                    Text("📸")
                    Text(event.note)
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let eventCardDay: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "E, MMM d"
        return df
    }()
    static let eventCardTime: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }()
}

