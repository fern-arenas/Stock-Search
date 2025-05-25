import Foundation

protocol StockSearchService {
    func stocks<T: Decodable>(value valueType: StockValueType) async throws -> [T]
    func stockCache() async throws -> [String: Stock]?
    func saveCache(_ cache: [String: Stock]) async throws
}

final class StockSearchApiService: StockSearchService {
    func stocks<T: Decodable>(value valueType: StockValueType) async throws -> [T] {
        guard let url = URL(string: URLs.baseURL + valueType.rawValue)
        else { throw NetworkError.invalidURL }
        
        let response: StockResponse<T> = try await APIService.shared.get(url: url)
        return response.stocks
    }
    
    func stockCache() async throws -> [String: Stock]? {
        try await APIService.shared.load(url: URLs.cacheURL)
    }
    
    func saveCache(_ cache: [String: Stock]) async throws {
        try await APIService.shared.save(cache, url: URLs.cacheURL)
    }
}

private struct StockResponse<T: Decodable>: Decodable {
    let stocks: [T]
}
