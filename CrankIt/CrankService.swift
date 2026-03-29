import Foundation
import Combine

struct CrankPost {
    let quote: String
    let url: String
    let title: String
    let comment: String
    let isDraft: Bool
    let tags: [String]
    
    // This builds your specific Markdown format
    var markdownBody: String {
            let tagString = tags.map { "#\($0)" }.joined(separator: " ")
            let footer = comment.isEmpty ? "" : "\n\n\(comment)"
            
            return """
            > \(quote)

            [\(title)](\(url))
            \(footer)

            \(tagString)
            """
        }
}

class CrankService: ObservableObject {
    @Published var isPosting = false
    
    // We will store this in AppStorage (Settings) later
    // For now, we'll pass it in dynamically to keep it out of the source code
    func publish(post: CrankPost, token: String, blogUrl: String) async -> Bool {
        guard let endpoint = URL(string: "\(blogUrl)/micropub") else { return false }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let status = post.isDraft ? "draft" : "published"
        
        // Constructing the body for Micro.blog (Micropub protocol)
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "h", value: "entry"),
            URLQueryItem(name: "content", value: post.markdownBody),
            URLQueryItem(name: "post-status", value: status),
            URLQueryItem(name: "category[]", value: post.tags.joined(separator: ","))
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            // 201 Created or 202 Accepted means we win
            return (201...202).contains(httpResponse.statusCode)
        } catch {
            print("Crank It Error: \(error)")
            return false
        }
    }
    
    // The "Scraper" logic
    func fetchTitle(from urlString: String) async -> String {
        guard let url = URL(string: urlString) else { return "[TKTitle]" }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let html = String(data: data, encoding: .utf8) ?? ""
            
            // Simple Regex to find <title>...</title>
            if let titleRange = html.range(of: "<title[^>]*>(.*?)</title>", options: [.regularExpression, .caseInsensitive]) {
                let title = html[titleRange]
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return title.isEmpty ? "[TKTitle]" : title
            }
        } catch {
            return "[TKTitle]"
        }
        return "[TKTitle]"
    }
}

