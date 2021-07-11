import Foundation
import UIKit

@MainActor
class AlbumsViewModel: ObservableObject {
    
    private let albumService: AlbumService
    private let favoritesService: FavoritesService
    private let recommendationService = RecommendationService()
    
    @Published var allAlbums = [Album]() {
        didSet {
            updateFavorites()
        }
    }
    @Published var favorites = [Bool]()
    @Published var recommendedAlbums = [Album]()
    
    init(albumService: AlbumService,
         favoritesService: FavoritesService) {
        self.albumService = albumService
        self.favoritesService = favoritesService
    }
    
    func loadAlbums() async {
        do {
            self.allAlbums = try await albumService.fetchAlbums()
            try await makeRecommendations()
        } catch {
            print("error loading albums")
        }
    }
    
    func favoriteButtonTapped(for album: Album) {
        if isFavorite(album: album) {
            favoritesService.removeFromFavorites(album: album)
        } else {
            favoritesService.addToFavorites(album: album)
        }
        updateFavorites()
        async {
            try await makeRecommendations()
        }
    }
    
    func isFavorite(album: Album) -> Bool {
        return favoritesService.isFavorite(album: album)
    }
    
    // MARK: - private
    
    private func makeRecommendations() async throws {
        async {
            var favoriteAlbums = [Album]()
            for (index, value) in favorites.enumerated() {
                if value == true {
                    let album = allAlbums[index]
                    favoriteAlbums.append(album)
                }
            }
            do {
                self.recommendedAlbums = try await recommendationService.prediction(for: favoriteAlbums,
                                                                                    allAlbums: allAlbums)
            } catch {
                print(error)
                self.recommendedAlbums = []
            }
        }
    }
    
    private func updateFavorites() {
        var temp = [Bool](repeating: false, count: allAlbums.count)
        for (index, album) in allAlbums.enumerated() {
            if favoritesService.isFavorite(album: album) {
                temp[index] = true
            }
        }
        favorites = temp
    }
    
}

struct Album: Codable, Identifiable, Equatable, Hashable {
    let name: String
    let artist: String
    let artwork: String
    let keywords: [String]
    
    var id: String {
        "\(name)-\(artist)"
    }
    
    var image: UIImage {
        UIImage(named: artwork)!
    }
}
