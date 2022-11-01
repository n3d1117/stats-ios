//
//  MainView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import DependencyInjection

struct MainView: View {

    @StateObject private var dataLoader = NetworkDataLoader()

    @State private var showCharts = false

    @AppStorage("listLayout") private var listLayout = false

    var body: some View {
        TabView {
            ForEach(Route.allCases, id: \.hashValue) { route in
                NavigationView {
                    ZStack {
                        Color("bg_color").ignoresSafeArea()
                        route.associatedView
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
        .environment(\.listLayout, listLayout)
        .task {
            await dataLoader.load()
        }
    }
    
    private var layoutButton: some View {
        Button {
            listLayout.toggle()
        } label: {
            Image(systemName: listLayout ? "square.grid.2x2" : "list.bullet")
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
        case .success(_): return true
        default: return false
        }
    }
}

private struct LayoutSwitchKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var listLayout: Bool {
    get { self[LayoutSwitchKey.self] }
    set { self[LayoutSwitchKey.self] = newValue }
  }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWithMock(MainView()) {
            DependencyValues[\.networkService] = .mock(movies: [.inception], wait: true)
        }
    }
}
