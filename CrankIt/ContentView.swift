import SwiftUI

struct ContentView: View {
    // This connects to the shared "tunnel" we built in the App Group
    @AppStorage("microBlogToken", store: UserDefaults(suiteName: "group.blog.marniewebb.crankit"))
    private var token: String = ""
    
    @AppStorage("microBlogUrl", store: UserDefaults(suiteName: "group.blog.marniewebb.crankit"))
    private var blogUrl: String = "https://micro.blog"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Micro.blog Settings")) {
                    SecureField("App Token", text: $token)
                    TextField("Blog URL", text: $blogUrl)
                }
                
                Section(footer: Text("Once you save your token here, it will be available in the 'Crank It' share extension in Safari.")) {
                    if token.isEmpty {
                        Text("⚠️ Please enter your token to begin.")
                            .foregroundColor(.red)
                    } else {
                        Text("✅ Token saved to shared tunnel.")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Crank It ⚙️")
        }
    }
}
