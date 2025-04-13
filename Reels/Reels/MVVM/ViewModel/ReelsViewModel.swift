// MARK: - ReelsViewModel.swift
import Foundation
import RealmSwift

class ReelsViewModel {
    var reels: [Reel] = []
    var page = 1
    var pageSize = 10
    var isLoading = false // Add this to avoid duplicate API calls
    
    func loadInitialReels(completion: @escaping () -> Void) {
        fetchFromAPI {
            DispatchQueue.main.async {
                self.reels = RealmManager.shared.fetchAll(Reel.self)
                if self.reels.isEmpty {
                    let dummyReels: [Reel] = [
                        Reel(value: ["id": "1", "mediaURL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", "isVideo": true]),
                        Reel(value: ["id": "2", "mediaURL": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", "isVideo": true]),
                        Reel(value: ["id": "3", "mediaURL": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", "isVideo": true]),
                        Reel(value: ["id": "4", "mediaURL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", "isVideo": true]),
                        Reel(value: ["id": "5", "mediaURL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg", "isVideo": true])
                    ]
                    RealmManager.shared.save(dummyReels)
                    self.reels = dummyReels
                }
                completion()
            }
        }
    }

    func fetchFromAPI(completion: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true
        NetworkManager.shared.fetchReels(page: page, pageSize: pageSize) { result in
            self.isLoading = false
            switch result {
            case .success(let reelDTOs):
                let newReels = reelDTOs.map { dto -> Reel in
                    let reel = Reel()
                    reel.id = dto.id
                    reel.mediaURL = dto.mediaURL
                    reel.isVideo = dto.isVideo
                    return reel
                }
                RealmManager.shared.save(newReels)
                self.reels += newReels
                self.page += 1
                completion()
            case .failure(let error):
                print("Error fetching reels: \(error.localizedDescription)")
                completion()
            }
        }
    }

    func toggleLike(for index: Int) {
        let reel = reels[index]
        let reelRef = ThreadSafeReference(to: reel)
        DispatchQueue.main.async {
            let realm = RealmManager.shared.getRealm()
            guard let resolvedReel = realm.resolve(reelRef) else { return }
            do {
                try realm.write {
                    resolvedReel.isLiked.toggle()
                }
            } catch {
                print("Error toggling like: \(error.localizedDescription)")
            }
        }
    }
}

