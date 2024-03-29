//
//  MediaDetailView.swift
//  Stats
//
//  Created by ned on 02/12/22.
//

import Models
import NukeUI
import SwiftUI

struct MediaDetailView: View {
    @StateObject private var viewModel = MediaDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    let media: Media?

    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: [Color("bg_color"), viewModel.dominantColor.opacity(0.5)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                .opacity(0.5)
                .ignoresSafeArea()

            if let media {
                VStack(alignment: .leading) {
                    headerView(for: media)
                        .padding([.horizontal, .bottom])
                    
                    switch media {
                    case let show as TVShow:
                        if !show.episodes.isEmpty {
                            showDetailsView(for: show)
                        }
                    case let movie as Movie:
                        movieDetailsView(for: movie)
                    default:
                        EmptyView()
                    }
                }
                .padding(.top, 25)
            }
        }
        .task {
            if let imageURL = media?.imageURL {
                await viewModel.extractDominantColor(for: imageURL)
            }
        }
    }
    
    private func movieDetailsView(for movie: Movie) -> some View {
        Label(movie.lastWatched.formatted(), systemImage: "calendar")
            .foregroundColor(.secondary)
            .padding([.horizontal, .bottom])
    }
    
    private func showDetailsView(for show: TVShow) -> some View {
        VStack(alignment: .leading) {
            Text("\(show.episodes.count) episodes")
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 6)

            ScrollView(showsIndicators: false) {
                Divider().padding(.horizontal)

                ForEach(show.episodes) { episode in
                    HStack {
                        LazyImage(url: show.imageURL) { state in
                            if let image = state.image {
                                image
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .redacted(reason: .placeholder)
                            }
                        }
                        .aspectRatio(show.aspectRatio, contentMode: .fit)
                        .frame(width: 27)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

                        VStack(alignment: .leading) {
                            Text("\(episode.episode) — \(episode.name)")
                            Text(episode.lastWatched.formatted())
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                }
                .padding(.horizontal)
            }
        }
    }

    private func headerView(for media: Media) -> some View {
        HStack(alignment: .top, spacing: 15) {
            LazyImage(url: media.imageURL) { state in
                if let image = state.image {
                    image
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .redacted(reason: .placeholder)
                }
            }
            .aspectRatio(media.aspectRatio, contentMode: .fit)
            .frame(width: 110)
            .if(media is Artist, transform: { $0.clipShape(Circle()) })
            .if(!(media is Artist), transform: { $0.clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous)) })

            VStack(alignment: .leading, spacing: 7) {
                Text(media.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 25, weight: .semibold, design: .rounded))

                if let subtitle = media.subtitle {
                    Text(subtitle)
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }

                externalLinkUrl(for: media)
            }
            Spacer()
        }
    }

    private func externalLinkUrl(for media: Media) -> some View {
        Button {
            if let url = viewModel.extractUrl(from: media) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 5) {
                Text("Link")
                    .font(.system(size: 15))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundColor(.primary.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(BounceButtonStyle())
        .padding(.vertical, 3)
    }
}

struct MediaDetailView_Previews: PreviewProvider {
    struct Preview: View {
        var body: some View {
            MediaDetailView(media: Movie.inception)
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.dark)
    }
}
