import SwiftUI
import Firebase

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    let teamID: String
    let members: [Member]
    let onAdd: () -> Void
    @State private var teamAName: String = ""
    @State private var teamBName: String = ""
    @State private var selectedVolunteerID: String? = nil
    @State private var eventDate: Date = Date()
    @State private var eventTitle: String = ""
    @State private var eventLocation: String = ""
    @State private var eventNote: String = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Remove the duplicate header here (keep only navigationTitle)
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Teams")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Team A Name", text: $teamAName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)
                                .onChange(of: teamAName) { _ in updateTitle() }
                            TextField("Team B Name", text: $teamBName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)
                                .onChange(of: teamBName) { _ in updateTitle() }

                            Text("Snack Volunteer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Picker("Volunteer", selection: $selectedVolunteerID) {
                                Text("None").tag(String?.none)
                                ForEach(members, id: \.id) { member in
                                    Text(member.parentName).tag(Optional(member._id))
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 6)

                            Text("Date & Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            DatePicker("Event Date & Time", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .padding(.vertical, 6)

                            Text("Location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            TextField("Event Location", text: $eventLocation)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)

                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            TextField("Notes (e.g. Picture Day)", text: $eventNote)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    Button(action: addEvent) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Add Event")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(isSubmitting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(.plain)
                    .disabled(isSubmitting || teamAName.isEmpty || teamBName.isEmpty)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Always auto-generate the event title as "TeamA vs TeamB"
    private func updateTitle() {
        if !teamAName.isEmpty && !teamBName.isEmpty {
            eventTitle = "\(teamAName) vs \(teamBName)"
        } else {
            eventTitle = ""
        }
    }

    private func addEvent() {
        guard !isSubmitting else { return }
        isSubmitting = true
        let db = Firestore.firestore()
        let volunteerName = members.first(where: { $0._id == selectedVolunteerID })?.parentName
        let autoTitle = (!teamAName.isEmpty && !teamBName.isEmpty) ? "\(teamAName) vs \(teamBName)" : ""
        let eventData: [String: Any] = [
            "teamAName": teamAName,
            "teamBName": teamBName,
            "snackVolunteerID": selectedVolunteerID ?? "",
            "snackVolunteerName": volunteerName ?? "",
            "eventDate": Timestamp(date: eventDate),
            "title": autoTitle,
            "location": eventLocation,
            "note": eventNote
        ]
        let newDoc = db.collection("teams").document(teamID).collection("events").document()
        newDoc.setData(eventData) { err in
            isSubmitting = false
            if err == nil { onAdd(); dismiss() }
        }
    }
}
