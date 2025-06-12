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

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Teams")) {
                    TextField("Team A Name", text: $teamAName)
                    TextField("Team B Name", text: $teamBName)
                }
                Section(header: Text("Snack Volunteer")) {
                    Picker("Volunteer", selection: $selectedVolunteerID) {
                        Text("None").tag(String?.none)
                        ForEach(members, id: \.id) { member in
                            Text(member.parentName).tag(Optional(member._id))
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Date & Time")) {
                    DatePicker("Event Date & Time", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Title")) {
                    TextField("Event Title", text: $eventTitle)
                }
                Section(header: Text("Location")) {
                    TextField("Event Location", text: $eventLocation)
                }
                Section(header: Text("Notes")) {
                    TextField("Notes (e.g. Picture Day)", text: $eventNote)
                }
                Section {
                    Button("Add Event") {
                        addEvent()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Add Event")
        }
    }

    private func addEvent() {
        let db = Firestore.firestore()
        let volunteerName = members.first(where: { $0._id == selectedVolunteerID })?.parentName
        let eventData: [String: Any] = [
            "teamAName": teamAName,
            "teamBName": teamBName,
            "snackVolunteerID": selectedVolunteerID ?? "",
            "snackVolunteerName": volunteerName ?? "",
            "eventDate": Timestamp(date: eventDate),
            "title": eventTitle,
            "location": eventLocation,
            "note": eventNote
        ]
        let newDoc = db.collection("teams").document(teamID).collection("events").document()
        newDoc.setData(eventData) { err in
            if err == nil { onAdd(); dismiss() }
        }
    }
}
