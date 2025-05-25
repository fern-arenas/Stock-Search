struct SearchQuery: Hashable {
    let value: String
    var isEmpty: Bool { value.isEmpty }

    init(_ raw: String) {
        self.value = raw
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
