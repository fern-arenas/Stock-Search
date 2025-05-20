import SwiftUI

@main
struct Stock_SearchApp: App {
    var body: some Scene {
        WindowGroup {
            let service = StockSearchApiService()
            let provider = StockSearchProvider(service: service)
            let screenModel = StockSearchScreenModel(provider: provider)
            return StockSearchScreen(viewModel: screenModel)
        }
        
    }
}
