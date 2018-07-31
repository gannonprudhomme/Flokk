//
//  FeedViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

let initialPostsCount = 5

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // Serves as a queue / priority queue?
    // Sorted by date, although hopefully Firebase fills it sorted automatically
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        fillEmptyPosts()
        
        self.tableView.reloadData()
        
        // Load initial amount of posts
        
        // Add listener for new posts
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check for posts that the user just uploaded
        
        // Sort the posts? Just in case??
        
        // Check if there were any
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop the new posts listener
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

// MARK: Stuff
extension FeedViewController {
    // Initial post loading
    func loadPosts() {
        
    }
    
    // When we scroll down past a certain point, load more posts
    // Completion handler?
    func loadMorePosts() {
        
    }
    
    // Temporary function to fill in the posts
    fileprivate func fillEmptyPosts() {
        var videoURL = Bundle.main.path(forResource: "clip1", ofType: "m4v")
        
        let post = Post(url: URL(fileURLWithPath: videoURL!), dimensions: Dimensions(width: 1920, height: 1080), timestamp: 0)
        
        self.posts.append(post)
        
    }
}

// MARK: - Table View Functions
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        cell.post = self.posts[indexPath.row]
        cell.addVideoToView()
        
        
        
        //cell.addVideoToView()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        // Check if we've reached the bottom of the table
        if distanceFromBottom < height {
            // If so, start loading the other posts
        }
    }
}

