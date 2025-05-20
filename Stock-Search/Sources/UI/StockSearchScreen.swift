import SwiftUI

@MainActor
protocol StockSearchScreenViewModel: ObservableObject {
    var screenState: StockSearchScreenState? { get }
    var query: String { get set }
}

struct StockSearchScreen<ViewModel>: View
where ViewModel: StockSearchScreenViewModel {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchBar
                .padding()
            
            ScrollView {
                Group {
                    switch viewModel.screenState {
                    case .loading:
                        loadingStateView
                    case .empty:
                        emptyStateView
                    case let .error(message):
                        errorStateView(message)
                    case let .content(stocks):
                        contentStateView(stocks)
                    case .none:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            isSearchFocused = true
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(L10n.searchFieldPlaceholder, text: $viewModel.query)
                .focused($isSearchFocused)
                .disableAutocorrection(true)
                .accessibilityLabel(L10n.searchFieldAccessibilityLabel)
        }
        .padding(Size.small)
        .background(
            RoundedRectangle(cornerRadius: Size.small)
                .fill(Color(.systemGray5))
        )
    }
    
    private var loadingStateView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Size.small) {
            Text(L10n.emptyStateText)
                .foregroundColor(.secondary)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func errorStateView(_ message: String) -> some View {
        VStack(spacing: Size.small) {
            Text(L10n.errorStateText)
                .font(.headline)
            
            Text(message)
        }
        .foregroundColor(.red)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
    
    private func contentStateView(_ stocks: [Stock]) -> some View {
        LazyVStack(spacing: Size.small) {
            ForEach(stocks) { stock in
                stockTile(stock)
            }
        }
    }
    
    private func stockTile(_ stock: Stock) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                    .accessibilityLabel(stock.name)
                
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(L10n.averagePrice(stock.avgPriceCurrency))
                    .accessibilityLabel(L10n.averagePriceAccLabel(stock.avgPriceCurrency))
                
                Text(L10n.currentPrice(stock.currentPriceCurrency))
                    .accessibilityLabel(L10n.currentPriceAccLabel(stock.currentPriceCurrency))
            }
            .font(.headline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Size.small)
    }
}

enum StockSearchScreenState: Equatable {
    case loading
    case empty
    case error(String)
    case content([Stock])
}
