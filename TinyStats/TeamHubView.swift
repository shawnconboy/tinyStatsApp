import SwiftUI

struct TeamHubView: View {
    let team: Team
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel: TeamHubViewModel
    @State private var showEditEvent: Bool = false
    @State private var selectedEvent: Event? = nil
    @State private var showAddEvent: Bool = false

    init(team: Team) {
        self.team = team
        _viewModel = StateObject(wrappedValue: TeamHubViewModel(team: team))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to the Team Hub")
                .font(.largeTitle.bold())

            Text("Here you'll find your team schedule, chat, and updates.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

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
                    if isAdminOrDev {
                        Button(action: { showAddEvent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Add Event")
                    }
                }
                .padding(.leading, 4)

                ForEach(viewModel.events) { event in
                    Button(action: {
                        selectedEvent = event
                    }) {
                        EventCard(event: event)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
        .navigationTitle("Team Hub")
        .navigationBarTitleDisplayMode(.inline)
        // SIMPLIFY: Use .sheet(item:onDismiss:content:) directly on $selectedEvent
        .sheet(item: $selectedEvent, onDismiss: { viewModel.fetchEvents() }) { event in
            EditEventView(
                event: event,
                teamID: team.id,
                members: viewModel.members,
                onSave: { viewModel.fetchEvents() },
                onDelete: { viewModel.fetchEvents() }
            )
        }
        .sheet(isPresented: $showAddEvent, onDismiss: { viewModel.fetchEvents() }) {
            AddEventView(
                teamID: team.id,
                members: viewModel.members,
                onAdd: { viewModel.fetchEvents(); showAddEvent = false }
            )
        }
    }

    private var isAdminOrDev: Bool {
        let role = auth.adminProfile?.role
        return role == "admin" || role == "developer"
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

