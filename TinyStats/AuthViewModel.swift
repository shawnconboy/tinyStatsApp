import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - AdminProfile Model
struct AdminProfile {
    let id: String
    let name: String
    let email: String
    let organizationID: String
    let role: String
}

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?  // ✅ Corrected type reference
    @Published var adminProfile: AdminProfile?
    @Published var isProfileLoaded: Bool = false

    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user = user {
                self.fetchAdminProfile(for: user.uid)
            } else {
                self.adminProfile = nil
                self.isProfileLoaded = true
            }
        }
    }

    var isSignedIn: Bool {
        return user != nil
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let message: String

                switch AuthErrorCode.Code(rawValue: error.code) {
                case .wrongPassword:
                    message = "Incorrect password."
                case .invalidEmail:
                    message = "Please enter a valid email address."
                case .userNotFound:
                    message = "No account found for that email."
                case .networkError:
                    message = "Check your connection and try again."
                default:
                    message = "Something went wrong. Please try again."
                }

                completion(message)
            } else if let result = result {
                self.user = result.user
                self.fetchAdminProfile(for: result.user.uid)
                completion(nil as String?)  // ✅ Fix: explicitly cast nil
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.adminProfile = nil
            self.isProfileLoaded = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func fetchAdminProfile(for uid: String) {
        let db = Firestore.firestore()
        db.collection("admins")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch admin profile: \(error.localizedDescription)")
                    self.adminProfile = nil
                    self.isProfileLoaded = true
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    print("No admin profile found for UID: \(uid)")
                    self.adminProfile = nil
                    self.isProfileLoaded = true
                    return
                }

                let data = doc.data()
                let profile = AdminProfile(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    organizationID: data["organizationID"] as? String ?? "",
                    role: data["role"] as? String ?? ""
                )

                DispatchQueue.main.async {
                    self.adminProfile = profile
                    self.isProfileLoaded = true
                    print("✅ Loaded admin profile: \(profile)")
                }
            }
    }
}
