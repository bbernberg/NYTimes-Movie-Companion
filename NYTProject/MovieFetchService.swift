//
//  MovieFetchService.swift
//  NYTProject
//
//  Created by Brian Bernberg on 9/27/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import Foundation
import Alamofire

let NYTimesAPIKey = ""

class MovieFetchService {

    static let sharedInstance = MovieFetchService()
    var movies = [Movie]()
    
    func updateMovies(withOffset offset: Int = 0, completion: @escaping (_ success: Bool) -> Void) {
        let parameters: Parameters = ["api-key": NYTimesAPIKey,
                                      "order": "by-publication-date",
                                      "offset": offset]
        Alamofire.request("https://api.nytimes.com/svc/movies/v2/reviews/all.json",
                          parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let JSON = response.result.value as? [String: Any],
                    let movieResults = JSON["results"] as? [ [String: Any] ] {
                    self.store(movieResults: movieResults)
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func store(movieResults: [ [String: Any] ]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
                
        for movieJSON in movieResults {
            if let title = movieJSON["display_title"] as? String,
                let summary = movieJSON["summary_short"] as? String,
                let criticsPick = movieJSON["critics_pick"] as? Bool,
                let dateString = movieJSON["publication_date"] as? String,
                let linkInfo = movieJSON["link"] as? [String: AnyObject],
                let url = linkInfo["url"] as? String {
                    let movie = Movie(title: title,
                                      summary: summary,
                                      reviewURL: url,
                                      criticsPick: criticsPick,
                                      reviewDate: dateFormatter.date(from: dateString))
                    movies.append(movie)
            }
        }
    }
}
