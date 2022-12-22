//
//  String+Extension.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Foundation

extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

