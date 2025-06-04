// ... all imports unchanged ...
import SwiftUI
import FirebaseFirestore

struct TeamScheduleManager: View {
    let team: Team
    @State private var schedule: [TeamScheduleItem] = []
    @State private var isLoading = true
    @State private var showAddItem = false
    @State private var selectedItem: TeamScheduleItem? = nil
    @State private var showEditItem = false
    @State private var showDeleteAlert = false
    @State private var itemToDelete: TeamScheduleItem? = nil
    @State private var showGameDetailSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView("Loading schedule...")
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                HStack {
                    Text("Schedule (\(schedule.count))")
                        .font(.title3.bold())
                    Spacer()
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.bottom, 2)
                if schedule.isEmpty {
                    Text("No schedule items yet.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(schedule) { item in
                            let isUpcomingGame = item.type == "Game" && item.date >= Calendar.current.startOfDay(for: Date())
                            ScheduleItemRowView(item: item, onEdit: {
                                selectedItem = item
                                showEditItem = true
                            }, onDelete: {
                                itemToDelete = item
                                showDeleteAlert = true
                            })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isUpcomingGame {
                                    selectedItem = item
                                    showGameDetailSheet = true
                                }
                            }
                        }
                        .onDelete(perform: deleteItemsFromList)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear(perform: fetchSchedule)
        .sheet(isPresented: $showAddItem) {
            AddScheduleItemFormView(team: team) {
                showAddItem = false
                fetchSchedule()
            }
        }
        .sheet(isPresented: $showEditItem, onDismiss: { selectedItem = nil }) {
            if let item = selectedItem {
                EditScheduleItemFormView(item: item, team: team) {
                    showEditItem = false
                    fetchSchedule()
                }
            }
        }
        .sheet(isPresented: $showGameDetailSheet, onDismiss: { selectedItem = nil }) {
            if let item = selectedItem {
                GameDetailSheet(item: item)
            }
        }
        .alert("Delete Schedule Item?", isPresented: $showDeleteAlert, presenting: itemToDelete) { item in
            Button("Delete", role: .destructive) {
                deleteItem(item)
            }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("Are you sure you want to remove this item?")
        }
    }

    private func fetchSchedule() {
        let db = Firestore.firestore()
        isLoading = true
        db.collection("teams").document(team.id).collection("schedule")
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    let fetched = docs.compactMap { doc in
                        TeamScheduleItem(
                            id: doc.documentID,
                            date: (doc["date"] as? Timestamp)?.dateValue() ?? Date(),
                            type: doc["type"] as? String ?? "",
                            opponent: doc["opponent"] as? String,
                            time: doc["time"] as? String ?? "",
                            location: doc["location"] as? String ?? "",
                            snackParent: doc["snackParent"] as? String,
                            notes: doc["notes"] as? String
                        )
                    }
                    DispatchQueue.main.async {
                        self.schedule = fetched.sorted { $0.date < $1.date }
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
    }

    private func deleteItem(_ item: TeamScheduleItem) {
        let db = Firestore.firestore()
        guard let itemId = item.id else { return }
        db.collection("teams").document(team.id).collection("schedule").document(itemId).delete { error in
            if error == nil {
                fetchSchedule()
            } else {
                print("Error deleting item: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func deleteItemsFromList(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { schedule[$0] }
        for item in itemsToDelete {
            deleteItem(item)
        }
    }
}

struct ScheduleItemRowView: View {
    let item: TeamScheduleItem
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                let opponent = item.opponent ?? ""
                Text(item.type + ": " + (opponent.isEmpty ? "-" : opponent))
                    .font(.body.weight(.semibold))
                Text("Date: \(item.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                let location = item.location ?? ""
                if !location.isEmpty {
                    Text("Location: \(location)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.plain)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

struct AddScheduleItemFormView: View {
    let team: Team
    var onComplete: () -> Void
    @State private var type = "Game"
    @State private var opponent = ""
    @State private var date = Date()
    @State private var time = ""
    @State private var location = ""
    @State private var snackParent = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Game Info")) {
                    TextField("Type", text: $type)
                    TextField("Opponent", text: $opponent)
                    DatePicker("Date", selection: $date)
                    TextField("Time", text: $time)
                    TextField("Location", text: $location)
                    TextField("Snack Parent", text: $snackParent)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Add Schedule Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }.disabled(type.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onComplete() }
                }
            }
        }
    }

    private func addItem() {
        let db = Firestore.firestore()
        let itemData: [String: Any] = [
            "type": type,
            "opponent": opponent,
            "date": Timestamp(date: date),
            "time": time,
            "location": location,
            "snackParent": snackParent,
            "notes": notes
        ]
        db.collection("teams").document(team.id).collection("schedule").addDocument(data: itemData) { error in
            onComplete()
        }
    }
}

struct EditScheduleItemFormView: View {
    let item: TeamScheduleItem
    let team: Team
    var onComplete: () -> Void
    @State private var type: String
    @State private var opponent: String
    @State private var date: Date
    @State private var time: String
    @State private var location: String
    @State private var snackParent: String
    @State private var notes: String

    init(item: TeamScheduleItem, team: Team, onComplete: @escaping () -> Void) {
        self.item = item
        self.team = team
        self.onComplete = onComplete
        _type = State(initialValue: item.type)
        _opponent = State(initialValue: item.opponent ?? "")
        _date = State(initialValue: item.date)
        _time = State(initialValue: item.time ?? "")
        _location = State(initialValue: item.location ?? "")
        _snackParent = State(initialValue: item.snackParent ?? "")
        _notes = State(initialValue: item.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Game Info")) {
                    TextField("Type", text: $type)
                    TextField("Opponent", text: $opponent)
                    DatePicker("Date", selection: $date)
                    TextField("Time", text: $time)
                    TextField("Location", text: $location)
                    TextField("Snack Parent", text: $snackParent)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Edit Schedule Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateItem()
                    }.disabled(type.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onComplete() }
                }
            }
        }
    }

    private func updateItem() {
        let db = Firestore.firestore()
        db.collection("teams").document(team.id).collection("schedule").document(item.id ?? "").updateData([
            "type": type,
            "opponent": opponent,
            "date": Timestamp(date: date),
            "time": time,
            "location": location,
            "snackParent": snackParent,
            "notes": notes
        ]) { error in
            onComplete()
        }
    }
}
