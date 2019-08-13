//
//  WikiEntry.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

class WikiEntry: Codable {
    var parse: ParseEntry
}

class ParseEntry: Codable {
    let wikiText: WikiTextEntry
    
    private enum CodingKeys: String, CodingKey {
        case wikiText = "wikitext"
    }
}

class WikiTextEntry: Codable {
    let text: String
    
    private enum CodingKeys: String, CodingKey {
        case text = "*"
    }
}
