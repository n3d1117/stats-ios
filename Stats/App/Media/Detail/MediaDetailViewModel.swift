//
//  MediaDetailViewModel.swift
//  Stats
//
//  Created by ned on 03/12/22.
//

import DominantColor
import Foundation
import Nuke
import SwiftUI

@MainActor final class MediaDetailViewModel: ObservableObject {
    @Published private(set) var dominantColor: Color = .indigo

    func extractDominantColor(for imageURL: URL) async {
        do {
            let image = try await ImagePipeline.shared.image(for: imageURL).image
            if let primaryDominantColor = image.dominantColors().first {
                dominantColor = Color(primaryDominantColor)
            }
        } catch {
            print(error)
        }
    }
}
