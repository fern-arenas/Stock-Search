import Foundation

actor StockSearchProvider<Service>: StockSearchProviding
where Service: StockSearchService {
    private var cache: VersionedCache = .empty
    private var queryHistory: Set<SearchQuery> = []
    private let service: Service
    private var isCacheFresh: Bool {
        guard let cacheDate = cache.date,
              Date().timeIntervalSince(cacheDate) < 5 * 60
        else { return false }
        return true
    }
    
    init(service: Service) {
        self.service = service
    }
    
    func loadCache() async throws {
        if let offlineCache: VersionedCache = try await service.stockCache() {
            self.cache = offlineCache
        }
    }
    
    func stocks(query: SearchQuery) async throws -> [Stock] {
        let cachedStocks = checkCache(with: query)
        if !cachedStocks.isEmpty { return cachedStocks }
        
        async let historicalData: [HistoricalStock] = service.stocks(value: .historical)
        async let currentData: [CurrentStock] = service.stocks(value: .current)
        
        let (current, historical) = try await (currentData, historicalData)
        
        let stocks = try processStocks(query: query, historical: historical, current: current)
        
        updateQueryHistory(with: query)
        
        try await service.saveCache(cache)
        
        return stocks
    }
    
    private func checkCache(with query: SearchQuery) -> [Stock] {
        guard isCacheFresh else {
            queryHistory.removeAll()
            cache.values.removeAll()
            return []
        }
        
        // This check is added to avoid an issue with the user querying for "AT" and
        // then "A" the second query could return incomplete information due to cache containing an
        // "A" prefix
        guard !queryHistory.contains(where: { query.value.hasPrefix($0.value) })
        else { return [] }
        
        return cache.values
            .filter { $0.key.hasPrefix(query.value) }
            .map(\.value)
    }
    
    private func updateQueryHistory(with query: SearchQuery) {
        // Removes "AT" and replaces it with "A"
        for item in queryHistory where item.value.hasPrefix(query.value) {
            queryHistory.remove(item)
        }
        
        queryHistory.insert(query)
    }
    
    private func processStocks(
        query: SearchQuery,
        historical: [HistoricalStock],
        current: [CurrentStock]
    ) throws -> [Stock] {
        let currentById = Dictionary(uniqueKeysWithValues: current.map { ($0.id, $0) })
        var filtered: [Stock] = []
        var addedIds = Set<Int>()
        var cache: [String: Stock] = [:]
        
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
        
        try Task.checkCancellation()
        
        self.cache = .init(date: Date(), values: cache)
        
        return filtered.sorted { $0.ticker < $1.ticker }
    }
}
