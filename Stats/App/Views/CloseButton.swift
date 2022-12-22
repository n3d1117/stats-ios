//
//  CloseButton.swift
//  Stats
//
//  Created by ned on 22/12/22.
//

import SwiftUI

struct CloseButton: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary.opacity(0.7))
        }
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton()
    }
}
