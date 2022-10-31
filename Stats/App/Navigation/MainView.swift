//
//  MainView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

struct MainView: View {

    @StateObject private var dataLoader = NetworkDataLoader()

    @State private var showCharts = false

    var body: some View {
        TabView {
            ForEach(Route.allCases, id: \.hashValue) { route in
                NavigationView {
                    ZStack {
                        Color("bg_color").ignoresSafeArea()
                        route.associatedView
                            .navigationTitle(route.label)
                            .toolbar {
                                Button {
                                    showCharts.toggle()
                                } label: {
                                    Image(systemName: "chart.xyaxis.line")
                                }
                                .sheet(isPresented: $showCharts) {
                                    ZStack {
                                        Color("bg_color").ignoresSafeArea()
                                        StatsView()
                                    }
                                }

                            }
                    }
                }.tabItem {
                    Label(route.label, systemImage: route.image)
                }
            }
        }
        .environmentObject(dataLoader)
        .task {
            await dataLoader.load()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
