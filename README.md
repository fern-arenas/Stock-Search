# 📈 Stock Search App

A SwiftUI iOS application that allows users to search for stocks. The app uses MVVM architecture and async/await concurrency.

---
### Installation

1. Clone the repository:
```bash
 git clone https://github.com/neo-Fernando-Arenas/Stock-Search.git
```
2. Open the project in Xcode
3. Build and run on a simulator

---
### Architectural Overview
This project uses MVVM architecture and dependency injection to improve testability, separation of concerns, and modularity, layered as follows:

```
Model (Stock)
   ↕
View (StockSearchScreen)
   ↕
ViewModel (StockSearchScreenModel)
   ↕
Provider (StockSearchProvider)
   ↕
Service (StockSearchApiService)
```

---
### Component Breakdown
- #### StockSearchScreen
SwiftUI view that displays loading, error, empty, and result states

- #### StockSearchScreenModel
The ViewModel observes the query, debounces changes, and updates the screen state using async methods

- #### StockSearchProvider
Caches previous search results and merges historical and current stock data based on stock ID

- #### StockSearchApiService
A concrete implementation of the StockSearchService protocol that fetches stock data

---

### Assumptions and Simplifications
- An assumption was made to only cache the sctocks that resulted from the specific user search, eventhough realistically when I fetch the stocks the endpoint returns all of them so I could have cached all of them
  
- A debounce was added as a delay to not hit the end point too many times
  
- On the cache I stored the stocks twice with a different key in order to optimize for searching
  
- Assumes historical and current stock data can be joined reliably using id
  
- Not much focus was put on the UI in order to focus on the logic itself but the UI could be improved
  
- L10n struct for text, making future localization easier
  
- Dependency injection was used for testing
  
- Minor accessibility optimizations

## Made with 🫀 by Fernando Arenas 🙂
