//
//  MovieOpinionService.swift
//  NYTProject
//
//  Created by Brian Bernberg on 9/28/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import Foundation

class MovieOpinionService {
    static let sharedInstance = MovieOpinionService()
    private var opinions: [String: Opinion]
    
    init() {
        self.opinions = [String: Opinion]()
        self.loadOpinions()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.persistOpinions),
                                               name: Notification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    static func opinion(forValue value : Float) -> Opinion {
        switch value {
        case 0.0..<0.5:
            return .NotInterested
        case 0.5..<1.5:
            return .Neutral
        case 1.5..<2.5:
            return .Streaming
        default:
            return .Theater
        }
    }
    
    func add(opinion: Opinion, forMovie movie: Movie) {
        self.opinions[movie.title] = opinion
    }
    
    func getOpinionFor(movieTitle: String) -> Opinion {
        if let opinion = self.opinions[movieTitle] {
            return opinion
        }
        return .Neutral
    }
    
    
    
    func movieTitles(withOpinion opinion: Opinion) -> [String] {
        var result = [String]()
        
        for (movieTitle, movieOpinion) in self.opinions {
            if movieOpinion == opinion {
                result.append(movieTitle)
            }
        }
        return result
    }
    
    @objc func persistOpinions() {
        var rawOpinions = [String: NSNumber]()
        for (title, opinion) in self.opinions {
            rawOpinions[title] = NSNumber(integerLiteral: opinion.rawValue)
        }
        UserDefaults.standard.set(rawOpinions, forKey: "opinions")
        UserDefaults.standard.synchronize()
    }
    
    private func loadOpinions() {
        if let rawOpinions = UserDefaults.standard.dictionary(forKey: "opinions") as? [String: NSNumber] {
            for (title, rawOpinion) in rawOpinions {
                if let opinion = Opinion(rawValue: rawOpinion.intValue) {
                    self.opinions[title] = opinion
                }
            }
        }
    }
    
}
