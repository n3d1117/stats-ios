//
//  BooksView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Models
import DependencyInjection
import Networking

struct BooksView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    booksView(for: response.books)
                        .padding()
                }

            case .loading:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Dummy header")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        MoviesGridViewMock()
                    }
                    .padding()
                    .redacted(reason: .placeholder)
                }

            case .failed(let error):
                GenericErrorView(error: error.localizedDescription) {
                    await dataLoader.load()
                }
            }
        }
        .animation(.default, value: dataLoader.state)
    }

    private func booksView(for books: [Book]) -> some View {

        let reading: [Book] = books
            .filter { !$0.isFavorite }
            .filter { $0.reading }

        let recentlyRead = books
            .filter { !$0.isFavorite }
            .filter { !$0.reading }

        let favorites = books
            .filter { $0.isFavorite }

        return VStack(spacing: 30) {

            if !reading.isEmpty {
                VStack(alignment: .leading) {
                    Text("Reading")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    BooksGridView(books: reading)
                }
            }

            if !recentlyRead.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recently read")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    BooksGridView(books: recentlyRead)
                }
            }

            if !favorites.isEmpty {
                VStack(alignment: .leading) {
                    Text("Favorites")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    BooksGridView(books: favorites)
                }
            }
        }
    }
}

struct BooksGridView: View {

    let books: [Book]

    var body: some View {
        GridView {
            ForEach(books) { book in
                MediaGridItemView(
                    title: book.title,
                    subtitle: String(book.author),
                    imageURL: URL(string: (API.baseImageUrl + book.img).urlEncoded),
                    aspectRatio: 0.7,
                    circle: false
                )
            }
        }
    }
}

struct BooksGridView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            BooksView()
                .task {
                    DependencyValues[\.networkService] = .mock(books: [.open])
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
        }
    }

    static var previews: some View {
        Preview()
    }
}
