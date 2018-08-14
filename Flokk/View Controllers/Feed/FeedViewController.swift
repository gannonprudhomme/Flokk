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
    func uploadPost(fileURL: URL)
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // Serves as a queue / priority queue?
    // Sorted by date, although hopefully Firebase fills it sorted automatically
    //var posts = [Post]()
    
    var group: Group!
    
    let loadCount = 3 // Only load 3 posts at a time(after the initial 5)
    var currentPostCount = 0 // Start out at 0, increased within loadPostsData()
    var totalPostsCount = 10 // Max amount of posts we can load(the # of posts in the group)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Load the data for ALL of the posts in this group
        loadPostsData(completion: { (didLoadPosts) in
            // If posts were loaded
            if didLoadPosts {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // After we're done loading the data, load the initial videos
                self.loadPostVideos()
            } else { // If the posts are already loaded
                if self.group.posts.count < initialPostsCount {
                    self.currentPostCount = self.group.posts.count
                } else {
                    self.currentPostCount = initialPostsCount
                }
            }
        })
        
        //fillEmptyPosts()
        
        tableView.reloadData()
        
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
        performSegue(withIdentifier: "feedToCameraSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToCameraSegue" {
            if let vc = segue.destination as? CameraNavigationController {
                vc.uploadPostDelegate = self
            }
        }
    }
}

// MARK: - Post Handling
extension FeedViewController: UploadPostDelegate {
    // Initial post loading. Load all of the posts data, but not the video/preview-image files
    // Boolean in completion handler is true
    func loadPostsData(completion: @escaping (Bool) -> Void) {
        // If there posts isn't empty, then they have already been loaded
        if group.posts.count == 0 {
            database.child("groups").child(group.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : [String : Any]] {
                    for postID in value.keys {
                        let timestamp = value[postID]!["timestamp"] as! Double
                        let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                        
                        let post = Post(uid: postID, timestamp: timestamp)
                        post.setDimensions(width: 1080, height: 1920)
                        
                        // Simplt add it to the posts array
                        // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                        self.group.posts.append(post)
                    }
                    
                    // After loading in all of the posts, sort them
                    self.sortPosts()
                    
                    // Set how many posts to load, depending on how many we have
                    
                    if self.group.posts.count < initialPostsCount {
                        self.currentPostCount = self.group.posts.count
                    } else {
                        self.currentPostCount = initialPostsCount
                    }
                    
                    // Done loading posts data, call completion with true, meaning posts have actually been loaded
                    completion(true)
                }
            })
        } else {
            // No posts needed to be loaded, so call completion false
            completion(false)
        }
    }
    
    func loadPostVideos() {
        // Create the directory for the posts to be stored
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("groups/\(group.uid)/posts")
        
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        
        for i in 0..<currentPostCount {
            let post = group.posts[i]
            
            var url = outputURL.appendingPathComponent("\(post.uid).mp4")
            
            storage.child("groups").child(group.uid).child("posts").child(post.uid).write(toFile: url, completion: { (url, error) in
                if error == nil {
                    post.fileURL = url
                    
                    // Update the according tableViewCell once the post has been loaded
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    }
                } else {
                    print("ERROR LOADING POST VIDEO")
                    print(error?.localizedDescription)
                    return
                }
            })
            
            /*
            storage.child("groups").child(group.uid).child("posts").child(post.uid).downloadURL(completion: { (url, error) in
                if error == nil {
                    post.fileURL = url
                    //post.fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "clip1", ofType: ".m4v")!)
                    
                    // Update the according tableViewCell once the post has been loaded
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    }
                } else {
                    print("ERROR LOADING POST VIDEO")
                    print(error?.localizedDescription)
                    return
                }
            }) */
        }
    }
    
    // When we scroll down past a certain point, load more posts
    // Completion handler?
    func loadMorePosts() {
        var postDiff = totalPostsCount - currentPostCount
        
        if postDiff > loadCount {
            postDiff = loadCount
        }
        
        var indexPaths = [IndexPath]()
        // currentPostCount is a size(aka size of 1 = index of 0), so i starts at 0
        for i in 0..<postDiff {
            indexPaths.append(IndexPath(row: currentPostCount + i, section: 0))
        }
        
        currentPostCount += postDiff
        
        //tableView.reloadData()
        tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
    }
    
    // Called in VideoPlaybackVC after the user has finalized the post
    func uploadPost(fileURL: URL) {
        // Generate a unique ID for this post
        let postID = database.child("groups").child(group.uid).child("posts").childByAutoId().key
        // Get the post upload time
        let timestamp = Date.timeIntervalSinceReferenceDate
        
        // Upload the post data to the database
        let postRef = database.child("groups").child(group.uid).child("posts").child(postID)
        postRef.child("poster").setValue(mainUser.uid)
        postRef.child("timestamp").setValue(timestamp)
        
        // Upload the video to Firebase Storage
        storage.child("groups").child(group.uid).child("posts").child(postID).putFile(from: fileURL)
        
        // Initialize the post
        let post = Post(uid: postID, timestamp: timestamp)
        post.fileURL = fileURL
        
        var dim = VideoUtils.resolutionForLocalVideo(url: fileURL)
        post.setDimensions(width: Int((dim?.width)!), height: Int((dim?.height)!))
        
        // Add the post to the posts array in the current Group
        group.addPost(post: post)
        
        currentPostCount += 1
        
        // Insert it into the top of the tableView, shifting the other
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    func sortPosts() {
        // Larger timestamp(more recent) should be at the top, so ascending order
        group.posts.sort(by: { $0.timestamp > $1.timestamp})
    }
}

// MARK: - Table View Functions
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        cell.post = group.posts[indexPath.row]
        cell.initialize()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPostCount
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
                //loadMorePosts()
            }
        }
    }
}

