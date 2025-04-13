// MARK: - NetworkManager.swift
import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    func fetchReels(page: Int, pageSize: Int, completion: @escaping (Result<[ReelDTO], Error>) -> Void) {
        let urlString = "https://example.com/api/reels?page=\(page)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -10)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -20)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ReelDTO].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
