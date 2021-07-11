//
//  AlbumService.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 9.7.21.
//

import Foundation

protocol AlbumService {
    
    func fetchAlbums() async throws -> [Album]
    
}

class LocalAlbumService: AlbumService {
    
    func fetchAlbums() async throws -> [Album] {
        let url = Bundle.main.url(forResource: "albums", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let albums = try JSONDecoder().decode([Album].self, from: json)
        return albums
    }
    
}
