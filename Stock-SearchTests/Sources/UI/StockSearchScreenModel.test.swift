import XCTest
@testable import Stock_Search

@MainActor
final class StockSearchScreenModelTests: XCTestCase {
    private var provider: MockStockSearchProvider!
    private var model: StockSearchScreenModel<MockStockSearchProvider>!
    
    override func setUp() {
        super.setUp()
        provider = .init()
        model = .init(provider: provider, debounceInterval: .zero)
    }

    func test_performSearch_setsScreenStateToContent() async throws {
        let stocks: [Stock] = [
            .init(id: 1, name: "ABC", ticker: "ABC", currentPrice: 100, avgPrice: 100),
            .init(id: 2, name: "ABCD", ticker: "ABCD", currentPrice: 100, avgPrice: 100)
        ]
        
        provider.result = .success(stocks)

        model.query = "ABC"
        try await Task.sleep(for: .seconds(0.01))

        XCTAssertEqual(model.screenState, .content(stocks))
    }

    func test_performSearch_setsScreenStateToEmpty() async throws {
        provider.result = .success([])

        model.query = "ABC"
        try await Task.sleep(for: .seconds(0.01))

        XCTAssertEqual(model.screenState, .empty)
    }

    func test_performSearch_setsScreenStateToError() async throws {
        provider.result = .failure(NSError(domain: "Test", code: 0))

        model.query = "ABC"
        try await Task.sleep(for: .seconds(0.01))

        if case let .error(message)? = model.screenState {
            XCTAssertTrue(message.contains("Test"))
        } else {
            XCTFail("Expected error state")
        }
    }

    func test_performSearch_setsScreenStateToNil() async throws {
        model.query = " "
        try await Task.sleep(for: .seconds(0.01))

        XCTAssertNil(model.screenState)
    }

    func test_debounceTaskCancelsPreviousTask() async throws {
        model.query = "A"
        model.query = "AB"
        model.query = "ABC"
        try await Task.sleep(for: .seconds(0.1))

        XCTAssertEqual(provider.receivedQuery?.value, "abc")
    }
    
}

private final class MockStockSearchProvider: StockSearchProviding {
    var result: Result<[Stock], Error> = .success([])
    private(set) var receivedQuery: SearchQuery?

    func stocks(query: SearchQuery) async throws -> [Stock] {
        self.receivedQuery = query
        switch result {
        case .success(let stocks): return stocks
        case .failure(let error): throw error
        }
    }
}
