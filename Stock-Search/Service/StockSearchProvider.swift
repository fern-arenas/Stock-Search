import Foundation

actor StockSearchProvider<Service>: StockSearchProviding
where Service: StockSearchService {
    private var cache: [String: Stock] = [:]
    private var lastCachedQuery: SearchQuery = .init("")
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func stocks(query: SearchQuery) async throws -> [Stock] {
        let cachedStocks = checkCache(with: query)
        if !cachedStocks.isEmpty { return cachedStocks }
        
        async let historicalData: [HistoricalStock] = service.stocks(value: .historical)
        async let currentData: [CurrentStock] = service.stocks(value: .current)
        
        let (current, historical) = try await (currentData, historicalData)
        
        lastCachedQuery = query
        
        return processStocks(query: query, historical: historical, current: current)
    }
    
    private func checkCache(with query: SearchQuery) -> [Stock] {
        // This check is added to avoid an issue with the user querying for "AT" and
        // then "A" the second query could return incomplete information due to cache containing an
        // "A" prefix
        if query.value.hasPrefix(lastCachedQuery.value) {
            return cache
                .filter { $0.key.hasPrefix(query.value) }
                .map { $0.value }
        }
        
        return []
    }
    
    private func processStocks(
        query: SearchQuery,
        historical: [HistoricalStock],
        current: [CurrentStock]
    ) -> [Stock] {
        let currentById = Dictionary(uniqueKeysWithValues: current.map { ($0.id, $0) })
        var filtered: [Stock] = []
        var addedIds = Set<Int>()
        
        for historicalStock in historical {
            guard let currentStock = currentById[historicalStock.id] else { continue }
            
            let stock = Stock(historicalStock: historicalStock, currentStock: currentStock)

            let nameKey = historicalStock.name.lowercased()
            let tickerKey = historicalStock.ticker.lowercased()
            
            // Stocks added twice to cache to optimize for search on name and ticker
            cache[nameKey] = stock
            cache[tickerKey] = stock
            
            let matchesQuery = nameKey.hasPrefix(query.value) || tickerKey.hasPrefix(query.value)
            let isDuplicated = !addedIds.insert(stock.id).inserted
            
            if matchesQuery, !isDuplicated {
                filtered.append(stock)
            }
        }
        
        return filtered.sorted { $0.ticker < $1.ticker }
    }
}
