import Foundation

enum SocialLinkType: String, CaseIterable {
    case x
    case instagram
    case youtube
    case snapchat
    case facebook
    case tiktok
    
    var storageKey: String { rawValue }
    
    var iconName: String {
        switch self {
        case .x: return "ic_x"
        case .instagram: return "ic_instagram"
        case .youtube: return "ic_youtube"
        case .snapchat: return "ic_snapchat"
        case .facebook: return "ic_facebook"
        case .tiktok: return "ic_tiktok"
        }
    }
    
    var placeholder: String {
        switch self {
        case .x:
            return "username or x.com/username"
        case .instagram:
            return "username or instagram.com/username"
        case .youtube:
            return "Channel URL or youtube.com/@channel"
        case .snapchat:
            return "username or snapchat.com/add/username"
        case .facebook:
            return "Profile URL or facebook.com/username"
        case .tiktok:
            return "username or tiktok.com/@username"
        }
    }
    
    func url(from rawValue: String) -> URL? {
        let trimmed = rawValue.trimmed
        guard !trimmed.isEmpty else { return nil }
        
        if let directURL = normalizedURL(from: trimmed) {
            return directURL
        }
        
        let sanitized = trimmed.replacingOccurrences(of: "@", with: "").replacingOccurrences(of: " ", with: "")
        
        let urlString: String
        switch self {
        case .x:
            urlString = "https://x.com/\(sanitized)"
        case .instagram:
            urlString = "https://instagram.com/\(sanitized)"
        case .youtube:
            if trimmed.hasPrefix("@") {
                urlString = "https://youtube.com/\(trimmed)"
            } else {
                urlString = "https://youtube.com/@\(sanitized)"
            }
        case .snapchat:
            urlString = "https://www.snapchat.com/add/\(sanitized)"
        case .facebook:
            urlString = "https://facebook.com/\(sanitized)"
        case .tiktok:
            urlString = "https://www.tiktok.com/@\(sanitized)"
        }
        
        return URL(string: urlString)
    }
    
    private func normalizedURL(from string: String) -> URL? {
        let lowercased = string.lowercased()
        if lowercased.hasPrefix("http://") || lowercased.hasPrefix("https://") {
            return URL(string: string)
        }
        
        if lowercased.contains("://") {
            return URL(string: string)
        }
        
        if lowercased.contains(".com") {
            return URL(string: "https://\(string)")
        }
        
        return nil
    }
}

