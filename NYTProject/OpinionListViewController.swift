//
//  OpinionListViewController.swift
//  NYTProject
//
//  Created by Brian Bernberg on 9/28/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

extension Opinion {
    func sectionTitle() -> String {
        switch self {
        case .Theater:
            return "Theater Movies"
        case .Streaming:
            return "Movies to Stream"
        default:
            return "Not Interested"
        }
    }
}

class OpinionListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var movieTitles = [Opinion: [String]]()
    var sections = [Opinion]()
    
    // MARK: View controller lifecyle functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
        self.tableView.reloadData()
    }
    
    // MARK: data refresh
    private func refreshData() {
        self.sections = []
        
        let theaterTitles = MovieOpinionService.sharedInstance.movieTitles(withOpinion: .Theater)
        self.movieTitles[.Theater] = theaterTitles
        if theaterTitles.count > 0 {
            self.sections.append(.Theater)
        }
        
        let streamingTitles = MovieOpinionService.sharedInstance.movieTitles(withOpinion: .Streaming)
        self.movieTitles[.Streaming] = streamingTitles
        if streamingTitles.count > 0 {
            self.sections.append(.Streaming)
        }
        
        let notInterestedTitles = MovieOpinionService.sharedInstance.movieTitles(withOpinion: .NotInterested)
        self.movieTitles[.NotInterested] = notInterestedTitles
        if notInterestedTitles.count > 0 {
            self.sections.append(.NotInterested)
        }
    }
    
}

extension OpinionListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let opinion = self.sections[section]
        guard let sectionMovieTitles = self.movieTitles[opinion] else {
            return 0
        }
        return sectionMovieTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opinion = self.sections[indexPath.section]
        guard let sectionMovieTitles = self.movieTitles[opinion] else {
            return UITableViewCell()
        }
        let movieTitle = sectionMovieTitles[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpinionCellID", for: indexPath)
        cell.textLabel?.text = movieTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let opinion = self.sections[section]
        return opinion.sectionTitle()
    }
    
    
    
    
}
