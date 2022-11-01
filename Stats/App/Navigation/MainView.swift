//
//  MainView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import DependencyInjection
import SwiftUI

enum LayoutType: String {
    case grid
    case list

    static let storageKey: String = "layoutType"
}

struct MainView: View {

    @StateObject private var dataLoader = NetworkDataLoader()

    @State private var showCharts = false

    @AppStorage(LayoutType.storageKey) private var layoutType: LayoutType = .grid

    var body: some View {
        TabView {
            ForEach(Route.allCases, id: \.hashValue) { route in
                NavigationView {
                    ZStack {
                        Color("bg_color").ignoresSafeArea()
                        MediaView(mediaType: route)
                            .navigationTitle(route.label)
                            .toolbar {
                                layoutButton
                                chartsButton
                            }
                    }
                }.tabItem {
                    Label(route.label, systemImage: route.image)
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
            Image(systemName: layoutType == .grid ? "square.grid.2x2" : "list.bullet")
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
            ZStack {
                Color("bg_color").ignoresSafeArea()
                StatsView()
                    .environmentObject(dataLoader)
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

private struct LayoutSwitchKey: EnvironmentKey {
    static let defaultValue: LayoutType = .grid
}

extension EnvironmentValues {
    var layoutType: LayoutType {
        get { self[LayoutSwitchKey.self] }
        set { self[LayoutSwitchKey.self] = newValue }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWithMock(MainView()) {
            DependencyValues[\.networkService] = .mock(movies: [.inception], wait: true)
            DependencyValues[\.persistenceService] = .mock
        }
    }
}
