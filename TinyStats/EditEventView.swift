import SwiftUI
import Firebase

struct EditEventView: View, Identifiable {
    var id: String { event._id }
    @Environment(\.dismiss) var dismiss
    @State var event: Event
    let teamID: String
    let members: [Member]
    let onSave: () -> Void
    let onDelete: () -> Void
    @State private var selectedVolunteerID: String?
    @State private var teamAName: String = ""
    @State private var teamBName: String = ""
    @State private var eventDate: Date = Date()
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var eventTitle: String = ""
    @State private var eventLocation: String = ""
    @State private var eventNote: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Remove the duplicate header here (keep only navigationTitle)
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            TextField("Title", text: $eventTitle)
                            TextField("Location", text: $eventLocation)
                            DatePicker("Date & Time", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                            HStack {
                                Text("Team A:")
                                TextField("Team A Name", text: $teamAName)
                            }
                            HStack {
                                Text("Team B:")
                                TextField("Team B Name", text: $teamBName)
                            }
                            Picker("Snack Volunteer", selection: $selectedVolunteerID) {
                                Text("None").tag(String?.none)
                                ForEach(members, id: \.id) { member in
                                    Text(member.parentName).tag(Optional(member._id))
                                }
                            }
                            .pickerStyle(.menu)
                            TextField("Notes (e.g. Picture Day)", text: $eventNote)
                        }
                        .padding(.vertical, 6)
                        .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    Button(action: saveEvent) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    Button(action: deleteEvent) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Event")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            selectedVolunteerID = event.snackVolunteerID
            teamAName = event.teamAName
            teamBName = event.teamBName
            eventDate = event.eventDate
            eventTitle = event.title
            eventLocation = event.location
            eventNote = event.note
        }
        .overlay(
            Group {
                if showToast {
                    Text(toastMessage)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }, alignment: .top
        )
    }

    private func saveEvent() {
        let db = Firestore.firestore()
        let volunteerName = members.first(where: { $0._id == selectedVolunteerID })?.parentName
        let updatedEvent = Event(
            _id: event._id,
            teamAName: teamAName,
            teamBName: teamBName,
            snackVolunteerID: selectedVolunteerID,
            snackVolunteerName: volunteerName,
            eventDate: eventDate,
            title: eventTitle,
            location: eventLocation,
            note: eventNote
        )
        let eventData: [String: Any] = [
            "teamAName": updatedEvent.teamAName,
            "teamBName": updatedEvent.teamBName,
            "snackVolunteerID": updatedEvent.snackVolunteerID ?? "",
            "snackVolunteerName": updatedEvent.snackVolunteerName ?? "",
            "eventDate": Timestamp(date: updatedEvent.eventDate),
            "title": updatedEvent.title,
            "location": updatedEvent.location,
            "note": updatedEvent.note
        ]
        db.collection("teams").document(teamID).collection("events").document(updatedEvent._id).setData(eventData, merge: true) { err in
            if err == nil {
                toastMessage = "Event saved!"
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showToast = false }
                }
                onSave()
                dismiss()
            } else {
                toastMessage = "Error updating event: \(err!.localizedDescription)"
                showToast = true
            }
        }
    }
    private func deleteEvent() {
        let db = Firestore.firestore()
        db.collection("teams").document(teamID).collection("events").document(event._id).delete { err in
            if err == nil {
                toastMessage = "Event deleted."
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showToast = false }
                }
                onDelete()
                dismiss()
            } else {
                toastMessage = "Error deleting event: \(err!.localizedDescription)"
                showToast = true
            }
        }
    }
}
