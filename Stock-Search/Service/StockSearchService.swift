import Foundation

protocol StockSearchService {
    func stocks<T: Decodable>(value valueType: StockValueType) async throws -> [T]
}

final class StockSearchApiService: StockSearchService {
    func stocks<T: Decodable>(value valueType: StockValueType) async throws -> [T] {
        guard let url = URL(string: URLs.baseURL + valueType.rawValue)
        else { throw NetworkError.invalidURL }
        
        let response: StockResponse<T> = try await APIService.shared.get(url: url)
        return response.stocks
    }
}

private struct StockResponse<T: Decodable>: Decodable {
    let stocks: [T]
}
