import Combine
import Foundation

protocol StockSearchProviding {
    func stocks(query: SearchQuery) async throws -> [Stock]
}

final class StockSearchScreenModel<Provider>: StockSearchScreenViewModel
where Provider: StockSearchProviding {
    @Published var screenState: StockSearchScreenState?
    var query: String = "" {
        didSet {
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(for: debounceInterval)
                if Task.isCancelled { return }
                await performSearch(for: .init(query))
            }
        }
    }
    
    private var debounceTask: Task<Void, Never>?
    private let provider: Provider
    private let debounceInterval: Duration
    
    init(provider: Provider, debounceInterval: Duration = .seconds(0.5)) {
        self.provider = provider
        self.debounceInterval = debounceInterval
    }

    private func performSearch(for query: SearchQuery) async {
        guard !query.isEmpty else {
            screenState = nil
            return
        }
        
        screenState = .loading
        
        do {
            screenState = .content(try await provider.stocks(query: query))
            
            if shouldShowEmptyState() {
                screenState = .empty
            }
        } catch {
            screenState = .error(error.localizedDescription)
        }
    }
    
    private func shouldShowEmptyState() -> Bool {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }

        if case let .content(stocks) = screenState {
            return stocks.isEmpty
        }

        return false
    }
}
