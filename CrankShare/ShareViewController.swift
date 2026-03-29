import SwiftUI
import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        var quote = ""
        var url = ""
        
        // 1. Check for highlighted text (The Quote)
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let text = item.attributedContentText?.string {
                quote = text
            }
            
            // 2. Check for the URL
            if let attachment = item.attachments?.first {
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                    guard let self = self else { return }
                    if let urlData = data as? URL {
                        url = urlData.absoluteString
                    }
                    
                    // 3. Jump to the Main Thread to show the UI
                    DispatchQueue.main.async {
                        let hostingController = UIHostingController(rootView: CrankShareView(
                            quote: quote,
                            url: url,
                            extensionContext: self.extensionContext
                        ))
                        self.addChild(hostingController)
                        self.view.addSubview(hostingController.view)
                        hostingController.view.frame = self.view.bounds
                    }
                }
            }
        }
    }
}

struct CrankShareView: View {
    @State var quote: String
    @State var url: String
    @State var title: String = "[Fetching...]"
    @State var comment: String = ""
    @State var isDraft: Bool = true
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var service = CrankService()
    var extensionContext: NSExtensionContext?

    // Shared "Locker" for the token
    @AppStorage("microBlogToken", store: UserDefaults(suiteName: "group.blog.marniewebb.crankit"))
    private var token: String = ""
    @AppStorage("microBlogUrl", store: UserDefaults(suiteName: "group.blog.marniewebb.crankit"))
    private var blogUrl: String = "https://micro.blog"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("The Quote")) {
                    Text(quote)
                        .font(.system(.body, design: .serif))
                        .italic()
                }
                
                Section(header: Text("The Source")) {
                    TextField("Title", text: $title).bold()
                    TextField("URL", text: $url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Your Comment")) {
                                    VStack(alignment: .trailing) {
                                        TextEditor(text: $comment)
                                            .frame(minHeight: 100)
                                        
                                        Text("\(comment.count) / 280")
                                            .font(.caption2)
                                            .monospacedDigit()
                                            .foregroundColor(comment.count > 280 ? .red : .secondary)
                                            .padding(.top, 4)
                                    }
                                }
                
                Section {
                    Toggle("Save as Draft", isOn: $isDraft)
                }
                
                Button(action: { postToMicroBlog() }) {
                    Text("Crank It")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .disabled(token.isEmpty)
            }
            .navigationTitle("Crank It ⚙️")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    }
                }
            }
            .alert(alertMessage, isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                Task {
                    if !url.isEmpty {
                        self.title = await service.fetchTitle(from: url)
                    }
                }
            }
        }
    }
    
    func postToMicroBlog() {
        let tagArray: [String] = [] // No #CrankIt tag
        let post = CrankPost(
            quote: quote,
            url: url,
            title: title,
            comment: comment,
            isDraft: isDraft,
            tags: tagArray
        )
        
        Task {
            let success = await service.publish(post: post, token: token, blogUrl: blogUrl)
            if success {
                alertMessage = "Cranked! ⚙️"
                showSuccessAlert = true
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                alertMessage = "Error: Check your token in the main app."
                showSuccessAlert = true
            }
        }
    }
}
