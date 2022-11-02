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

    @AppStorage(MediaLayoutType.storageKey) private var layoutType: MediaLayoutType = .grid

    var body: some View {
        NavigationStack {
            ZStack {
                Color("bg_color").ignoresSafeArea()
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
        .task {
            await dataLoader.load()
        }
    }

    private var layoutButton: some View {
        Button {
            layoutType = layoutType == .grid ? .list : .grid
        } label: {
            Image(systemName: layoutType == .list ? "square.grid.2x2" : "list.bullet")
        }
        .disabled(!buttonsEnabled)
    }

    private var chartsButton: some View {
        Button {
            showCharts.toggle()
        } label: {
            Image(systemName: "chart.xyaxis.line")
        }
        .disabled(!buttonsEnabled)
        .sheet(isPresented: $showCharts) {
            NavigationStack {
                ZStack {
                    Color("bg_color").ignoresSafeArea()
                    StatsView()
                        .navigationTitle("Stats")
                        .environmentObject(dataLoader)
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
            DependencyValues[\.networkService] = .mock(movies: [.inception], wait: false)
            DependencyValues[\.persistenceService] = .mock
        }
    }
}
