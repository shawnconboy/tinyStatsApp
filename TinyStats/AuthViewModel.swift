import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AdminProfile {
    let id: String
    let name: String
    let email: String
    let organizationID: String
    let role: String
    let teamID: String
}

struct MemberProfile {
    let id: String
    let name: String
    let email: String
    let childName: String
    let role: String
    let teamID: String
}

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var adminProfile: AdminProfile?
    @Published var memberProfile: MemberProfile?
    @Published var isProfileLoaded: Bool = false

    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user = user {
                self.fetchUserProfile(for: user.uid)
            } else {
                self.adminProfile = nil
                self.memberProfile = nil
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
                self.fetchUserProfile(for: result.user.uid)
                completion(nil)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.adminProfile = nil
            self.memberProfile = nil
            self.isProfileLoaded = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func fetchUserProfile(for uid: String) {
        let db = Firestore.firestore()

        db.collection("admins")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let doc = snapshot?.documents.first {
                    let data = doc.data()
                    let profile = AdminProfile(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        organizationID: data["organizationID"] as? String ?? "",
                        role: data["role"] as? String ?? "",
                        teamID: data["teamID"] as? String ?? ""
                    )
                    DispatchQueue.main.async {
                        self.adminProfile = profile
                        self.memberProfile = nil
                        self.isProfileLoaded = true
                        print("✅ Loaded admin profile: \(profile)")
                    }
                    return
                }

                db.collection("members")
                    .whereField("uid", isEqualTo: uid)
                    .getDocuments { snapshot, error in
                        if let doc = snapshot?.documents.first {
                            let data = doc.data()
                            let profile = MemberProfile(
                                id: doc.documentID,
                                name: data["name"] as? String ?? "",
                                email: data["email"] as? String ?? "",
                                childName: data["childName"] as? String ?? "",
                                role: data["role"] as? String ?? "",
                                teamID: data["teamID"] as? String ?? ""
                            )
                            DispatchQueue.main.async {
                                self.memberProfile = profile
                                self.adminProfile = nil
                                self.isProfileLoaded = true
                                print("✅ Loaded member profile: \(profile)")
                            }
                        } else {
                            print("❌ No admin or member profile found for UID: \(uid)")
                            self.isProfileLoaded = true
                        }
                    }
            }
    }
}
