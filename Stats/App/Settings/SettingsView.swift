//
// Created by ned on 08/12/22.
//

import SwiftUI
import NukeUI

struct SettingsView: View {
    
    @State private var point = CGPoint(x: 0, y: 0)
    @State private var degrees: Double = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                LazyImage(url: URL(string: "https://edoardo.fyi/me.jpeg")) { state in
                    if let image = state.image {
                        image
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .redacted(reason: .placeholder)
                    }
                }
                .scaledToFill()
                .padding()
                .frame(maxWidth: 200, maxHeight: 200)
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
                                point = CGPoint(x: 0, y: 0)
                                degrees = 0
                            }
                        }
                )
            }
            .frame(maxWidth: 200, maxHeight: 200)
        }
    }
}

fileprivate extension Comparable {
    func clamped(_ f: Self, _ t: Self)  ->  Self {
        var r = self
        if r < f { r = f }
        if r > t { r = t }
        return r
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
