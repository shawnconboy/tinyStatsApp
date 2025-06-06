import SwiftUI
import Firebase

struct ReviewJoinRequestView: View {
    let request: JoinRequest
    let onApprove: (Int) -> Void
    let onDeny: () -> Void

    @State private var jerseyNumber: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Review Request")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 12) {
                Text("Parent: \(request.parentName)")
                Text("Child: \(request.childName)")
                Text("Email: \(request.email)")

                TextField("Jersey Number", text: $jerseyNumber)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            HStack {
                Button("Deny", role: .destructive) {
                    onDeny()
                }

                Spacer()

                Button("Approve") {
                    if let num = Int(jerseyNumber) {
                        onApprove(num)
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}
