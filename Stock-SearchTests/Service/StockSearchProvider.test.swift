import XCTest
@testable import Stock_Search

@MainActor
final class StockSearchProviderTests: XCTestCase {
    private var mockService: MockStockSearchService!
    private var provider: StockSearchProvider<MockStockSearchService>!
    
    override func setUp() async throws {
        mockService = MockStockSearchService()
        provider = StockSearchProvider(service: mockService)
    }

    func test_returnsMergedAndFilteredStocks() async throws {
        mockService.historical = [
            HistoricalStock(id: 1, name: "AABCD", ticker: "AABCD", currentPrice: 1),
            HistoricalStock(id: 2, name: "ABCD", ticker: "ABCD", currentPrice: 1)
        ]
        
        mockService.current = [
            CurrentStock(id: 1, currentPrice: 150.0),
            CurrentStock(id: 2, currentPrice: 100.0)
        ]
        
        let result = try await provider.stocks(query: SearchQuery("aa"))
        
        let expectedStocks = Stock(
            historicalStock: mockService.historical[0],
            currentStock: mockService.current[0]
        )
        
        XCTAssertEqual(result, [expectedStocks])
    }

    func test_removesDuplicates() async throws {
        mockService.historical = [
            HistoricalStock(id: 1, name: "ABCD", ticker: "ABCD", currentPrice: 1),
            HistoricalStock(id: 1, name: "ABCD Inc", ticker: "ABCD", currentPrice: 1)
        ]
        mockService.current = [
            CurrentStock(id: 1, currentPrice: 123.0)
        ]
        
        let result = try await provider.stocks(query: SearchQuery("abc"))
        
        XCTAssertEqual(result.count, 1)
    }

    func test_returnsSortedResults() async throws {
        mockService.historical = [
            HistoricalStock(id: 1, name: "ABCD", ticker: "ABCD", currentPrice: 1),
            HistoricalStock(id: 2, name: "ACBD", ticker: "ACBD", currentPrice: 1)
        ]
        mockService.current = [
            CurrentStock(id: 1, currentPrice: 50),
            CurrentStock(id: 2, currentPrice: 60)
        ]
        
        let result = try await provider.stocks(query: SearchQuery("a"))
        let tickers = result.map(\.ticker)
        
        XCTAssertEqual(tickers, ["ABCD", "ACBD"])
    }
}

private final class MockStockSearchService: StockSearchService {
    var historical: [HistoricalStock] = []
    var current: [CurrentStock] = []
    
    func stocks<T>(value valueType: StockValueType) async throws -> [T] where T : Decodable {
        if valueType == .historical {
            return historical as! [T]
        } else {
            return current as! [T]
        }
    }
}
