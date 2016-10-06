//
//  MovieListTableViewController
//  NYTProject
//
//  Created by Brian Bernberg on 9/26/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit
import SafariServices

class MovieListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View controller lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = "NY Times Movie Companion"
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        MovieFetchService.sharedInstance.updateMovies() { [unowned self] (success) in
            if success {
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: nil, message: "Unable to load movies at this time", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: Control event handlers
    func showReviewFor(reviewButton: UIButton) {
        let movie = MovieFetchService.sharedInstance.movies[reviewButton.tag]
        guard let reviewURL = URL(string: movie.reviewURL) else {
            return
        }
       
        let svc = SFSafariViewController(url: reviewURL)
        self.present(svc, animated: true, completion: nil)
    }
    
    func valueChangedFor(slider: UISlider) {
        slider.value = round(slider.value)
        let movie = MovieFetchService.sharedInstance.movies[slider.tag]
        let opinion = MovieOpinionService.opinion(forValue: slider.value)
        MovieOpinionService.sharedInstance.add(opinion: opinion, forMovie: movie)
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieFetchService.sharedInstance.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellID", for: indexPath) as! MovieListTableViewCell
        let movie = MovieFetchService.sharedInstance.movies[indexPath.row]
        
        cell.movieTitleLabel.text = movie.title
        cell.reviewSummaryLabel.text = movie.summary
        cell.reviewButton.tag = indexPath.row // This will be used to determine which button was pressed
        cell.reviewButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.reviewButton.addTarget(self, action: #selector(self.showReviewFor(reviewButton:)), for: .touchUpInside)
        cell.criticsPickStackView.isHidden = !movie.criticsPick
        cell.slider.tag = indexPath.row
        cell.slider.value = Float(MovieOpinionService.sharedInstance.getOpinionFor(movieTitle: movie.title).rawValue)
        cell.slider.removeTarget(nil, action: nil, for: .allEvents)
        cell.slider.addTarget(self, action: #selector(self.valueChangedFor(slider:)), for: .valueChanged)
        
        return cell
    }
    
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let movieCount = MovieFetchService.sharedInstance.movies.count
        if indexPath.row >= movieCount - 5 {
            MovieFetchService.sharedInstance.updateMovies(withOffset: movieCount, completion: { [unowned self] (result) in
                self.tableView.reloadData()
            })
        }
    }
    
}
