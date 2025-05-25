import Foundation

enum URLs {
    static let baseURL: String = """
        https://gist.githubusercontent.com/rockarts/07e1f458e79ba521a7e62aec6b231479/raw/\
        75484217fab58cd86876ae0bc910bc61020978f5/
        """
    
    static let cacheURL: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("stock_cache.json")
}

enum StockValueType: String {
    case current = "current.json"
    case historical = "historical.json"
}

enum L10n {
    static let searchFieldPlaceholder = "Search stocks by name or ticker"
    static let searchFieldAccessibilityLabel = "Search Field"
    static let emptyStateText = "No results"
    static let errorStateText = "Error"
    static func averagePriceAccLabel(_ value: String) -> String {
        "Average price of \(value)"
    }
    static func currentPriceAccLabel(_ value: String) -> String {
        "Current price of \(value)"
    }
    static func currentPrice(_ value: String) -> String {
        "current \(value)"
    }
    static func averagePrice(_ value: String) -> String {
        "avg. \(value) "
    }
    
    enum ErrorMessages {
        static let invalidURL = "The URL is invalid."
        static let unknown = "An unknown network error occurred."
    }
}

enum Size {
    static let small: CGFloat = 10
    static let medium: CGFloat = 20
}
