//
//  MainView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import DependencyInjection
import SwiftUI

struct MainView: View {

    @StateObject private var dataLoader = NetworkDataLoader()

    @State private var selectedRoute: Route = .movies
    @State private var showCharts = false
    
    private let gradientColors: [Route: Color] = [
        .movies: .blue,
        .tvShows: .red,
        .books: .green,
        .music: .orange,
        .games: .yellow
    ]

    @AppStorage(MediaLayoutType.storageKey) private var layoutType: MediaLayoutType = .grid

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color("bg_color"), gradientColor.opacity(0.6)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                    .opacity(0.6)
                    .ignoresSafeArea()
                MediaView(mediaType: selectedRoute)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(selectedRoute.label)
                    .toolbarTitleMenu {
                        ForEach(Route.allCases, id: \.hashValue) { route in
                            let toggleBinding = Binding<Bool>(
                                get: { selectedRoute == route },
                                set: { _ in selectedRoute = route }
                            )
                            Toggle(isOn: toggleBinding) {
                                Label(route.label, systemImage: route.image)
                            }
                        }
                    }
                    .toolbar {
                        layoutButton
                        chartsButton
                    }
            }
        }
        .environmentObject(dataLoader)
        .environment(\.layoutType, layoutType)
        .environment(\.colorScheme, .dark)
        .task {
            await dataLoader.load()
        }
    }
    
    private var gradientColor: Color {
        gradientColors[selectedRoute] ?? .accentColor
    }

    private var layoutButton: some View {
        Button {
            layoutType = layoutType == .grid ? .list : .grid
        } label: {
            Image(systemName: layoutType == .list ? "square.grid.2x2" : "list.bullet")
        }
        .disabled(!buttonsEnabled)
        .foregroundColor(gradientColor)
    }

    private var chartsButton: some View {
        Button {
            showCharts.toggle()
        } label: {
            Image(systemName: "chart.xyaxis.line")
        }
        .disabled(!buttonsEnabled)
        .foregroundColor(gradientColor)
        .sheet(isPresented: $showCharts) {
            NavigationStack {
                ZStack {
                    LinearGradient(gradient: .init(colors: [Color("bg_color"), .purple.opacity(0.5)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                        .opacity(0.5)
                        .ignoresSafeArea()
                    switch dataLoader.state {
                    case .success(let response):
                        StatsViewV2(viewModel: .init(apiResponse: response))
                    default:
                        EmptyView()
                    }
                
                    //StatsView()
                        //.environmentObject(dataLoader)
                }
            }.environment(\.colorScheme, .dark)
        }
    }

    private var buttonsEnabled: Bool {
        switch dataLoader.state {
        case .success: return true
        default: return false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWithMock(MainView()) {
            DependencyValues[\.networkService] = .mock(movies: [.inception], wait: false)
            DependencyValues[\.persistenceService] = .mock
        }
    }
}
