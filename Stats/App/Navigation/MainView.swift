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
    @State private var showSettings = false

    private let gradientColors: [Route: Color] = [
        .movies: .blue,
        .tvShows: .red,
        .books: .green,
        .music: .orange,
        .games: .yellow,
    ]

    @AppStorage(MediaLayoutType.storageKey) private var layoutType: MediaLayoutType = .grid

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedRoute) {
                ForEach(Route.allCases, id: \.hashValue) { route in
                    MediaView(mediaType: route)
                        .tag(route)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(selectedRoute.label)
                .toolbarTitleMenu {
                    ForEach(Route.allCases, id: \.hashValue) { route in
                        let toggleBinding = Binding<Bool>(
                            get: { selectedRoute == route },
                            set: { _ in withAnimation { selectedRoute = route } }
                        )
                        Toggle(isOn: toggleBinding) {
                            Label(route.label, systemImage: route.image)
                        }
                    }
                }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    settingsButton
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    layoutButton
                    chartsButton
                }
            }
            .background(
                LinearGradient(gradient: .init(colors: [Color("bg_color"), gradientColor.opacity(0.6)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                .opacity(0.6)
            )
        }
        .environmentObject(dataLoader)
        .environment(\.layoutType, layoutType)
        .preferredColorScheme(.dark)
        .task {
            await dataLoader.load()
        }
    }

    private var gradientColor: Color {
        gradientColors[selectedRoute] ?? .accentColor
    }

    private var layoutButton: some View {
        Menu {
            Section("Choose layout") {
                Button {
                    layoutType = .grid
                } label: {
                    Label("Grid", systemImage: "square.grid.2x2")
                }
                Button {
                    layoutType = .list
                } label: {
                    Label("List", systemImage: "list.bullet")
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.subheadline)
        }
        .disabled(!buttonsEnabled)
        .foregroundColor(gradientColor)
    }

    private var chartsButton: some View {
        Button {
            showCharts.toggle()
        } label: {
            Image(systemName: "chart.pie")
                .font(.subheadline)
        }
        .disabled(!buttonsEnabled)
        .foregroundColor(gradientColor)
        .sheet(isPresented: $showCharts) {
            NavigationStack {
                ZStack {
                    LinearGradient(gradient: .init(colors: [Color("bg_color"), .purple.opacity(0.5)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                        .opacity(0.5)
                        .ignoresSafeArea()
                    StatsView()
                        .environmentObject(dataLoader)
                }
            }
        }
    }

    private var settingsButton: some View {
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gear")
                .font(.subheadline)
        }
        .foregroundColor(gradientColor)
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                ZStack {
                    LinearGradient(gradient: .init(colors: [Color("bg_color"), .gray.opacity(0.5)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                        .opacity(0.5)
                        .ignoresSafeArea()
                    SettingsView()
                }
            }
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
            DependencyValues[\.networkService] = .mock(movies: [.inception], shows: [.boris], wait: false)
            DependencyValues[\.persistenceService] = .mock
        }
    }
}
