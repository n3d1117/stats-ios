//
// Created by ned on 08/12/22.
//

import SwiftUI
import NukeUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var point: CGPoint = .zero
    @State private var degrees: Double = 0
    @State private var imageHeight: CGFloat = 160
    
    var body: some View {
        List {
            Section {
                VStack {
                    imageView
                    titleView
                    madeByView
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.none)
            
            Section("Links") {
                LabeledContent("Website") {
                    Link("edoardo.fyi", destination: URL(string: "https://edoardo.fyi")!)
                }
                LabeledContent("GitHub") {
                    Link("n3d1117/stats-ios", destination: URL(string: "https://github.com/n3d1117/stats-ios")!)
                }
                LabeledContent("Donate") {
                    Link("Buy me a Coffee", destination: URL(string: "https://buymeacoff.ee/ne_do")!)
                }
            }
            .listRowBackground(Color(UIColor.darkGray).opacity(0.25))
            
            Section("Third party libraries") {
                Link("kean/Nuke", destination: URL(string: "https://github.com/kean/Nuke.git")!)
                Link("mergesort/Boutique", destination: URL(string: "https://github.com/mergesort/Boutique")!)
                Link("malcommac/SwiftDate", destination: URL(string: "https://github.com/malcommac/SwiftDate")!)
                Link("indragiek/DominantColor", destination: URL(string: "https://github.com/indragiek/DominantColor")!)
            }
            .listRowBackground(Color(UIColor.darkGray).opacity(0.25))
        }
        .scrollContentBackground(.hidden)
        .overlay(alignment: .topTrailing) {
            CloseButton()
                .padding()
        }
    }
    
    private var imageView: some View {
        GeometryReader { geometry in
            LazyImage(url: URL(string: "https://edoardo.fyi/me.jpeg")) { state in
                if let image = state.image {
                    image
                        .clipShape(Circle())
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .clipShape(Circle())
                        .redacted(reason: .placeholder)
                }
            }
            .scaledToFill()
            .padding(5)
            .frame(width: imageHeight, height: imageHeight)
            .contentShape(Rectangle())
            .rotation3DEffect(.degrees(degrees), axis: (x: point.x, y: point.y, z: 0))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let centerX = geometry.size.width / 2
                        let centerY = geometry.size.height / 2
                        
                        let x = 0 - (gesture.location.y / centerY - 1)
                        let y = (gesture.location.x / centerX - 1)
                        
                        let x1 = gesture.location.x - centerX
                        let y1 = gesture.location.y - centerY
                        
                        let range = sqrt(x1 * x1 + y1 * y1)
                        let degreesFactor = range / sqrt(2 * centerX * centerX)
                        
                        withAnimation {
                            point = CGPoint(x: x, y: y)
                            degrees = Double(15 * degreesFactor.clamped(0, 1))
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            point = .zero
                            degrees = 0
                        }
                    }
            )
        }
        .frame(width: imageHeight, height: imageHeight)
    }
    
    private var titleView: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Stats")
                .font(.title)
                .fontWeight(.semibold)
            
            if let appVersion = viewModel.appVersion {
                Text("v" + appVersion)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 1)
    }
    
    private var madeByView: some View {
        Group {
            Text("Made with ") + Text(Image(systemName: "heart")).font(.caption).baselineOffset(2) + Text(" by ned")
        }
        .foregroundColor(.secondary)
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
