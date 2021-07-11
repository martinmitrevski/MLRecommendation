//
//  FavoritesService.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 10.7.21.
//

import Foundation

protocol FavoritesService {
    
    func isFavorite(album: Album) -> Bool
    
    func addToFavorites(album: Album)
    
    func removeFromFavorites(album: Album)
    
}

class LocalFavoritesService: FavoritesService {
    
    private struct Constants {
        static let favoritesKey = "FavoritesKey"
    }
    
    func isFavorite(album: Album) -> Bool {
        loadFavorites().contains(album.id)
    }
    
    func addToFavorites(album: Album) {
        var favorites = loadFavorites()
        favorites.append(album.id)
        save(favorites: favorites)
    }
    
    func removeFromFavorites(album: Album) {
        var favorites = loadFavorites()
        favorites.removeAll { key in
            album.id == key
        }
        save(favorites: favorites)
    }
    
    //MARK: - private
    
    private func loadFavorites() -> [String] {
        UserDefaults.standard.value(forKey: Constants.favoritesKey) as? [String] ?? []
    }
    
    private func save(favorites: [String]) {
        UserDefaults.standard.set(favorites, forKey: Constants.favoritesKey)
    }
    
}
