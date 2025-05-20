import Foundation

enum NetworkError: Error, LocalizedError {
    private typealias Strings = L10n.ErrorMessages
    
    case invalidURL
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Strings.invalidURL
        case .unknown:
            return Strings.unknown
        }
    }
}
