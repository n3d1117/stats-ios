//
//  String+Extension.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Foundation
import Models
import Networking

extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

extension Media {
    var imageURL: URL? {
        URL(string: (API.baseImageUrl + image).urlEncoded)
    }
}
