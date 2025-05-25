import Foundation

struct Stock: Identifiable, Equatable, Codable {
    let id: Int
    let name: String
    let ticker: String
    let currentPrice: Double
    let avgPrice: Double
    
    var avgPriceCurrency: String {
        avgPrice.toCurrency()
    }
    
    var currentPriceCurrency: String {
        currentPrice.toCurrency()
    }
    
    init(historicalStock: HistoricalStock, currentStock: CurrentStock) {
        let avgPrice = (historicalStock.currentPrice + currentStock.currentPrice) / 2
        
        self.id = historicalStock.id
        self.name = historicalStock.name
        self.ticker = historicalStock.ticker
        self.currentPrice = currentStock.currentPrice
        self.avgPrice = avgPrice
    }
    
    init(id: Int, name: String, ticker: String, currentPrice: Double, avgPrice: Double) {
        self.id = id
        self.name = name
        self.ticker = ticker
        self.currentPrice = currentPrice
        self.avgPrice = avgPrice
    }
}

private extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: self)) ?? "-"
    }
}
