//
//  MLRecommendationApp.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 9.7.21.
//

import SwiftUI

@main
struct MLRecommendationApp: App {
    
    var body: some Scene {
        WindowGroup {
            let albumService = LocalAlbumService()
            let favoritesService = LocalFavoritesService()
            
            AlbumsView(viewModel: AlbumsViewModel(albumService: albumService,
                                                  favoritesService: favoritesService))
        }
    }
}
