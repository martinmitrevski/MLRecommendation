//
//  AlbumsView.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 9.7.21.
//

import SwiftUI

struct AlbumsView: View {
    
    @StateObject var viewModel: AlbumsViewModel
    
    private let columns = [GridItem(.adaptive(minimum: 300))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    if viewModel.recommendedAlbums.count > 0 {
                        VStack(alignment: .leading) {
                            HeaderView(title: "Suggested for you")
                            
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(viewModel.recommendedAlbums) { album in
                                        AlbumCard(viewModel: viewModel, album: album)
                                    }
                                }
                            }
                        }
                    }
                    
                    HeaderView(title: "Browse albums")
                    
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.allAlbums) { album in
                            AlbumCard(viewModel: viewModel,
                                      album: album)
                        }
                    }

                }
            }
            .navigationBarTitle("Albums")
            .onAppear {
                async {
                    await viewModel.loadAlbums()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct AlbumCard: View {
    
    @StateObject var viewModel: AlbumsViewModel
    let album: Album
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                AlbumInfo(album: album)
                
                Spacer()
                
                FavoriteButton(isFavorite: viewModel.isFavorite(album: album)) {
                    viewModel.favoriteButtonTapped(for: album)
                }

            }
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
        }
        .frame(height: 250)
        .background(
            Image(uiImage: album.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .allowsHitTesting(false)
        )
        .border(Color(white: 0.95))
        .cornerRadius(16)
        .modifier(DefaultPadding())
    }
    
}

struct AlbumInfo: View {
    
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(album.name)
                .font(.title3)
            Text(album.artist)
                .font(.headline)
        }
        .modifier(DefaultPadding())
    }
    
}

struct FavoriteButton: View {
    
    var isFavorite: Bool
    var onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .renderingMode(.template)
                .foregroundColor(.white)
        }
        .modifier(DefaultPadding())
    }
    
}

struct HeaderView: View {
    
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .modifier(DefaultPadding())
    }
    
}
