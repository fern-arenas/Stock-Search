struct HistoricalStock: Decodable {
    let id: Int
    let name: String
    let ticker: String
    let currentPrice: Double
}
