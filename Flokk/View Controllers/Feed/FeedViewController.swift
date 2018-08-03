//
//  FeedViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

// Is there a need for this to be global
let initialPostsCount = 5

// For telling the feed that we uploaded a photo from VideoPlaybackVC
// Passed along from Camera Nav -> Camera (-> maybe VideoTrimmer) -> VideoPlayback
protocol UploadPostDelegate {
    func uploadPost(fileID: String)
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // Serves as a queue / priority queue?
    // Sorted by date, although hopefully Firebase fills it sorted automatically
    var posts = [Post]()
    
    let loadCount = 3 // Only load 3 posts at a time(after the initial 5)
    var currentPostCount = initialPostsCount
    var totalPostsCount = 10 // Max amount of posts we can load(the # of posts in the group)
    
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
        
        // Stop the videos from being played
        
        for c in tableView.visibleCells {
            if let cell = c as? FeedTableViewCell {
                // Pause the video if it's playing and remove the observers
                cell.pauseVideo()
            }
        }
    }
    
    @IBAction func addPostPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "CameraNavigatonController")
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CameraNavigationController {
            vc.uploadPostDelegate = self
        }
    }
}

// MARK: - Post Handling
extension FeedViewController: UploadPostDelegate {
    // Initial post loading
    func loadPosts() {
        // Maybe get all of the posts (generic) info?
        
        // Only add the cell to the tableview when we have the preview image downloaded?
    }
    
    // When we scroll down past a certain point, load more posts
    // Completion handler?
    func loadMorePosts() {
        var postDiff = totalPostsCount - currentPostCount
        
        if postDiff > loadCount {
            postDiff = loadCount
        }
        
        //print("Loading \(postDiff) number of posts")
        
        var indexPaths = [IndexPath]()
        // currentPostCount is a size(aka size of 1 = index of 0), so i starts at 0
        for i in 0..<postDiff {
            indexPaths.append(IndexPath(row: currentPostCount + i, section: 0))
        }
        
        currentPostCount += postDiff
        
        //tableView.reloadData()
        tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
    }
    
    func uploadPost(fileID: String) {
        
    }
    
    func sortPosts() {
        // Larger timestamp(more recent) should be at the top, so ascending order
        posts.sort(by: { $0.timestamp < $1.timestamp})
    }
    
    // Temporary function to fill in the posts
    fileprivate func fillEmptyPosts() {
        let video1URL = Bundle.main.path(forResource: "clip1", ofType: "m4v")
        let video2URL = Bundle.main.path(forResource: "clip2", ofType: "mov")
        
        let post1 = Post(url: URL(fileURLWithPath: video1URL!), dimensions: Dimensions(width: 1920, height: 1080), timestamp: 0)
        let post2 = Post(url: URL(fileURLWithPath: video2URL!), dimensions: Dimensions(width: 1080, height: 1920), timestamp: 0)
        
        self.posts.append(post1)
        self.posts.append(post1)
        self.posts.append(post1)
        self.posts.append(post1)
        self.posts.append(post1)
        
        self.posts.append(post2)
        self.posts.append(post2)
        self.posts.append(post2)
        self.posts.append(post2)
        self.posts.append(post2)
    }
}

// MARK: - Table View Functions
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        cell.post = self.posts[indexPath.row]
        cell.initialize()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPostCount
        //return posts.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let feedCell = cell as? FeedTableViewCell {
            feedCell.pauseVideo()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        // Check if we've reached the bottom of the table
        if distanceFromBottom < height {
            // If so, start loading the other posts
            if currentPostCount < totalPostsCount {
                loadMorePosts()
            }
        }
    }
}

