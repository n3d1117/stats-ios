//
//  MainView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

struct MainView: View {

    @StateObject private var dataLoader = NetworkDataLoader()

    var body: some View {
        TabView {
            ForEach(Route.allCases, id: \.hashValue) { route in
                NavigationView {
                    ZStack {
                        Color("bg_color").ignoresSafeArea()
                        route.associatedView
                            .navigationTitle(route.label)
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
