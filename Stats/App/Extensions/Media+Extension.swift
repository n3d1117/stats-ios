//
//  Media+Extension.swift
//  Stats
//
//  Created by ned on 22/12/22.
//

import Foundation
import Models
import Networking

extension Media {
    var imageURL: URL? {
        URL(string: (API.baseImageUrl + image).urlEncoded)
    }
}
