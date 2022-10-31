//
//  GenericErrorView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

struct GenericErrorView: View {
    var title: String = "Oops, an error has occurred"
    var error: String
    var onRetry: (() async -> Void)?

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .padding(.bottom, 10)

            if let onRetry {
                Button {
                    Task {
                        await onRetry()
                    }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct GenericErrorView_Previews: PreviewProvider {
    static var previews: some View {
        GenericErrorView(error: "Example error", onRetry: {})
    }
}
