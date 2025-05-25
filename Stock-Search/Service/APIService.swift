import Foundation

final class APIService {
    static let shared: APIService = .init()
    private let encoder: JSONEncoder = .init()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedObject = try decoder.decode(T.self, from: data)
        
        return decodedObject
    }
    
    func save<T: Encodable>(_ item: T, url: URL) async throws {
        let data = try encoder.encode(item)
        try await Task.detached(priority: .utility) { [data] in
            try data.write(to: url, options: [.atomic])
        }.value
    }
    
    func load<T: Decodable>(url: URL) async throws -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try await Task.detached(priority: .utility) { [decoder] in
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        }.value
    }
}
