//
//  ApiService.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

class ApiService {
    private struct PatternConstants {
        static let firstListNameDescription = "\\|<center>\\s+\\{\\{bt-ruslat\\|(?<name>([\\w\\s])+)((.|\\n)+\\|){6}(?<description>.+)"
        static let firstListName = "\\|<center>\\s+\\{\\{bt-ruslat\\|(?<name>([\\w\\s])+)"
        static let secondList = "\\[\\[(?<name>.+?)(\\]\\]|\\|)"
    }
    
    static func getWikiInfo(
        onCompleted: @escaping ([PlantEntry]) -> Void,
        onError: @escaping (Error) -> Void
        ) {
        guard let url = URL(string: "\(NetWorkConstants.baseUrl)?action=parse&format=json&page=%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_%D0%BA%D0%BE%D0%BC%D0%BD%D0%B0%D1%82%D0%BD%D1%8B%D1%85_%D1%80%D0%B0%D1%81%D1%82%D0%B5%D0%BD%D0%B8%D0%B9&section=1&prop=wikitext") else {
            return
        }
        
        let request = URLRequest(url: url)
        
        if let data = URLCache.shared.cachedResponse(for: request)?.data,
            let wikiEntry = try? JSONDecoder().decode(WikiEntry.self, from: data) {
            onCompleted(convertToPlantEtries(rawString: wikiEntry.parse.wikiText.text))
        } else {
            loadFromApi(
                url: url,
                onCompleted: { (plantEntries) in
                    onCompleted(plantEntries)
                }, onError: { (error) in
                    onError(error)
            })
        }
    }
    
    private static func loadFromApi(
        url: URL,
        onCompleted: @escaping ([PlantEntry]) -> Void,
        onError: @escaping (Error) -> Void
        ) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                onError(error)
                return
            }
            
            guard let data = data,
                let response = response,
                let wikiEntry = try? JSONDecoder().decode(WikiEntry.self, from: data)
                else {
                    onError(NSError())
                    return
            }
            
            let cacheData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cacheData, for: request)
            
            onCompleted(convertToPlantEtries(rawString: wikiEntry.parse.wikiText.text))
        }
        task.resume()
    }
    
    private static func convertToPlantEtries(rawString: String) -> [PlantEntry] {
        let firstList = rawString.components(separatedBy: "|-")
        let secondList = firstList[firstList.count - 1].components(separatedBy: "*")
        
        var plants = [PlantEntry]()
        
        plants.append(contentsOf: getPlantsFromFirstList(list: firstList))
        plants.append(contentsOf: getPlantsFromSecondList(list: secondList))
        
        return plants
    }
    
    private static func getPlantsFromFirstList(list: [String]) -> [PlantEntry] {
        var plants = [PlantEntry]()

        let regexpNameDescription = try? NSRegularExpression(pattern: PatternConstants.firstListNameDescription, options: .caseInsensitive)
        let regexpName = try? NSRegularExpression(pattern: PatternConstants.firstListName, options: .caseInsensitive)
        
        for item in list {
            if let match = regexpNameDescription?.firstMatch(in: item, options: [], range: NSRange(location: 0, length: item.utf16.count)),
                let nameRange = Range(match.range(withName: "name"), in: item),
                let descriptionRange = Range(match.range(withName: "description"), in: item) {
                
                let plantName = String(item[nameRange].trimmingCharacters(in: .whitespacesAndNewlines))
                let plantDescription = String(item[descriptionRange].trimmingCharacters(in: .whitespacesAndNewlines))
                
                plants.append(PlantEntry(name: plantName, description: plantDescription))
            } else {
                if let match = regexpName?.firstMatch(in: item, options: [], range: NSRange(location: 0, length: item.utf16.count)),
                    let nameRange = Range(match.range(withName: "name"), in: item) {
                    
                    let plantName = String(item[nameRange].trimmingCharacters(in: .whitespacesAndNewlines))
                    
                    plants.append(PlantEntry(name: plantName, description: nil))
                }
            }
        }
        
        return plants
    }
    
    private static func getPlantsFromSecondList(list: [String]) -> [PlantEntry] {
        var plants = [PlantEntry]()

        let regexp = try? NSRegularExpression(pattern: PatternConstants.secondList, options: .caseInsensitive)
        
        for item in list {
            if let match = regexp?.firstMatch(in: item, options: [], range: NSRange(location: 0, length: item.utf16.count)),
                let nameRange = Range(match.range(withName: "name"), in: item) {
                
                let plantName = String(item[nameRange].trimmingCharacters(in: .whitespacesAndNewlines))
                
                plants.append(PlantEntry(name: plantName, description: nil))
            }
        }
        
        return plants
    }
}
