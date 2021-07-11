//
//  RecommendationService.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 10.7.21.
//

import Foundation
import CoreML
import TabularData
import CreateML

class RecommendationService {
            
    func prediction(for favoriteAlbums: [Album], allAlbums: [Album]) async throws -> [Album] {
        let allKeywords = allKeywords(from: allAlbums)
        let trainingData = prepareTrainingData(from: favoriteAlbums, allKeywords: allKeywords)
        let classifier = try await trainLinearRegressor(data: trainingData)
        let maxValues = try maxValues(for: favoriteAlbums, allAlbums: allAlbums, classifier: classifier)
        let average = computeAverage(from: maxValues)
        return sortAndFilter(from: maxValues, average: average)
    }
    
    //MARK: - private
    
    private func sortAndFilter(from maxValues: [Album: Double], average: Double) -> [Album] {
        var filtered = [Album: Double]()
        for (key, value) in maxValues {
            if value > average {
                filtered[key] = value
            }
        }
        
        return filtered.sorted { entry1, entry2 in
            return entry1.value > entry2.value
        }.map { (key, value) in
            key
        }
    }
    
    private func computeAverage(from maxValues: [Album: Double]) -> Double {
        var total: Double = 0
        for (_, value) in maxValues {
            total += value
        }
        let average = total / Double(maxValues.count)
        return average
    }
    
    private func maxValues(for favoriteAlbums: [Album],
                           allAlbums: [Album],
                           classifier: MLLinearRegressor) throws -> [Album: Double] {
        var maxValues = [Album: Double]()
        
        for album in allAlbums {
            if !favoriteAlbums.contains(album) {
                let keywordData = album.keywords.map { keyword in
                    [keyword: 1.0]
                }
                var inputData = DataFrame()
                inputData.append(column: Column(name: "keywords", contents: keywordData))
                let predictions = try classifier.predictions(from: inputData)
                var max: Double = 0
                for prediction in predictions {
                    if let value = prediction as? Double, value > max {
                        max = value
                    }
                }
                
                maxValues[album] = max
            }
        }
        
        return maxValues
    }
    
    private func allKeywords(from albums: [Album]) -> [String] {
        let keywords = albums.flatMap { album in
            album.keywords
        }.removingDuplicates()
        
        return keywords
    }
    
    private func featuresFromAlbumAndKeywords(album: String, keywords: [String]) -> [String: Double] {
        let featureNames = keywords + keywords.map {
            album + ":" + $0
        }
        
        return featureNames.reduce(into: [:]) { featureNames, name in
            featureNames[name] = 1.0
        }
    }
    
    private func prepareTrainingData(from albums: [Album], allKeywords: [String]) -> TrainingData {
        var trainingKeywords = [[String: Double]]()
        var trainingTargets = [Double]()
        
        for album in albums {
            let features = featuresFromAlbumAndKeywords(album: album.name,
                                                        keywords: album.keywords)
            trainingKeywords.append(features)
            trainingTargets.append(1.0)
            
            let negativeKeywords = allKeywords.filter { keyword in
                !album.keywords.contains(keyword)
            }
            
            trainingKeywords.append(featuresFromAlbumAndKeywords(album: album.name,
                                                                 keywords: Array(negativeKeywords)))
            trainingTargets.append(-1)
        }
        
        return TrainingData(trainingKeywords: trainingKeywords, trainingTargets: trainingTargets)
    }
    
    private func trainLinearRegressor(data: TrainingData) async throws -> MLLinearRegressor {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var trainingData = DataFrame()
                trainingData.append(column: Column(name: "keywords",
                                                   contents: data.trainingKeywords))
                trainingData.append(column: Column(name: "target",
                                                   contents: data.trainingTargets))
                
                do {
                    let model = try MLLinearRegressor(trainingData: trainingData, targetColumn: "target")
                    continuation.resume(returning: model)
                } catch {
                    continuation.resume(throwing: NSError(domain: "classifier",
                                                          code: 1,
                                                          userInfo: [:]))
                }
            }
        }
    }
    
}

struct TrainingData {
    var trainingKeywords: [[String: Double]]
    var trainingTargets: [Double]
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
