//
//  FeedViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation

// For telling the feed that we uploaded a photo from VideoPlaybackVC
// Passed along from Camera Nav -> Camera (-> maybe VideoTrimmer) -> VideoPlayback
protocol UploadPostDelegate {
    func uploadPost(fileURL: URL)
}

protocol NewPostDelegate {
    func newPost(post: Post)
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // Serves as a queue / priority queue?
    // Sorted by date, although hopefully Firebase fills it sorted automatically
    //var posts = [Post]()
    
    var group: Group!
    
    var currentPostCount = 0 // Start out at 0, increased within loadPostsData()
    
    var leaveGroupDelegate: LeaveGroupDelegate! // Used by GroupSettingsVC
    
    var postChangesHandle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = group.name
        
        // Load all of the post videos
        // This is assuming the data for this group has already been loaded
        loadPostVideos(startIndex: 0, count: group.posts.count)
        // addListeners()
        
        // Load the data for ALL of the posts in this group
        /*
        loadPostsData(completion: { (didLoadPosts) in
            // If posts were loaded
            if didLoadPosts {
                // Reload the tableView so we can
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // After we're done loading the data, load the initial videos
                self.loadPostVideos(startIndex: 0, count: self.currentPostCount)
                
                // Add listener for new posts
                self.addListeners()
            } else { // If the posts are already loaded
                // Set the post count, depending on how many there are
                // TODO: Iterate through all of the posts, and add all of the videos
                
                self.currentPostCount = self.group.posts.count
                
                // Add listener for new posts
                self.addListeners()
                //self.tableView.reloadData()
            }
        }) */
        
        // Handle this somewhere else
        //loadExtraGroupData()
        
        // TODO: Add listener for new posts
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //tableView.reloadData()
        
        // Check for posts that the user just uploaded
        
        // Check if there were any
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        group.feedDelegate = nil
        
        // Stop the new posts listener
        removeListeners()
        
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
        } else if segue.identifier == "feedToGroupSettingsSegue" {
            if let vc = segue.destination as? GroupSettingsViewController {
                vc.group = group
                vc.leaveGroupDelegate = leaveGroupDelegate
            }
        }
    }
}

// MARK: - Post Handling
extension FeedViewController: UploadPostDelegate, NewPostDelegate {
    func load() {
        // First check if the group data is not loaded
        if group.posts.count == 0 {
            // If there is a local file
            if let value = FileUtils.loadJSON(file: "groups/\(self.group.uid)") {
                // Read from the local file
                processGroupData(value: value)
                
                let groupRef = database.child("groups").child(group.uid)
                
                // Download and compare the database data
                // If there are new posts/members, insert them
                // Query by the most recent timestamp to only get new posts
                // Add the new posts and download the video for them
                groupRef.child("posts").queryOrdered(byChild: "timestamp").queryStarting(atValue: group.newestPostTime).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(value)
                    if let value = snapshot.value as? [String : Any] {
                        // Iterate through all of the post IDs
                        // These should be completely new posts
                        var indexPaths = [IndexPath]()
                        for postID in value.keys {
                            let data = value[postID] as! [String : Any]
                            
                            let timestamp = data["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = data["width"] as! Int
                            let height = data["height"] as! Int
                            
                            let post = Post(uid: postID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Simplt add it to the posts array
                            // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                            self.group.posts.append(post)
                            
                        }
                        
                        // Sort the posts before adding them to the tableView
                        self.group.sortPosts()
                        
                        // Add all of the new posts to the tableView
                        // Doesn't matter what order the posts are in
                        DispatchQueue.main.async {
                            // Update the tableView
                        }
                    }
                })
                
                // Download the member data and compare, checking if we have a new user or not
                groupRef.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String : Any] {
                        //let oldMembers = self.group.members
                        let newMemberUIDs = value.keys as! [String]
                        
                        // Remove the matches between the new and old members
                        
                    }
                })
                
                // Save the new data locally
                // However, we don't know if the new posts(or members) are loaded yet, better to wait for now
                
            } else { // If there is no local file
                // Download the database data and load it directly in
                database.child("groups").child(group.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String : [String : Any]] {
                        for postID in value.keys {
                            let timestamp = value[postID]!["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = value[postID]!["width"] as! Int
                            let height = value[postID]!["height"] as! Int
                            
                            let post = Post(uid: postID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Simplt add it to the posts array
                            // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                            self.group.posts.append(post)
                        }
                        
                        // Save the post data after all of the posts are loaded
                        print(self.group.convertToDict())
                        FileUtils.saveToJSON(dict: self.group.convertToDict(), toPath: "groups/\(self.group.uid).json")
                        
                        // After loading in all of the posts, sort them
                        self.group.sortPosts()
                        
                        // Set how many posts to load, depending on how many we have
                        
                        // Done loading posts data, call completion with true, meaning posts have actually been loaded
                    }
                })
            }
        }
    }
    
    private func processGroupData(value: [String : Any]) {
        let members = value["members"] as! [String : String]
        let creatorUID = value["creator"] as! String
        
        group.creatorUID = creatorUID
        
        // Iterate over the members dictionary and add them to the Group's member array
        // Used in Group Settings to show who is in the group
        for uid in members.keys {
            let handle = members[uid]
            
            group.members.append(User(uid: uid, handle: handle!))
        }
        
        // Load the posts
        if let posts = value["posts"] as? [String : [String : Any]] {
            for postID in posts.keys {
                let timestamp = posts[postID]!["timestamp"] as! Double
                //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                let width = posts[postID]!["width"] as! Int
                let height = posts[postID]!["height"] as! Int
                
                let post = Post(uid: postID, timestamp: timestamp)
                post.setDimensions(width: width, height: height)
                
                // Simplt add it to the posts array
                // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                group.posts.append(post)
                
                if let _ = group.feedDelegate {
                    // Update the feed
                    //group.feedDelegate.newPost(post: post)
                }
            }
            
            // After loading in all of the posts, sort them
            group.posts.sort(by: { $0.timestamp > $1.timestamp})
            
            // Set the newest post time as the top most post
            if group.posts.count > 0 {
                group.newestPostTime = group.posts[0].timestamp
            } else { // If there are no posts
                // TOOD: Set the timestamp to the group's creation date
                //group.newestPostTime = group.creationDate
                group.newestPostTime = 0
            }
            
            // Update the tableView
            
        }
    }
    
    // Initial post loading. Load all of the posts data, but not the video/preview-image files
    // Boolean in completion handler is true
    func loadPostsData(completion: @escaping (Bool) -> Void) {
        // If there posts isn't empty, then they have already been loaded
        if group.posts.count == 0 {
            // Check if the data has been stored locally by attempting to load the data
            if let value = FileUtils.loadJSON(file: "groups/\(group.uid).json") {
                // Load in the post data from the json dictionary
                let members = value["members"] as! [String : String]
                let creatorUID = value["creator"] as! String
                
                self.group.creatorUID = creatorUID
                
                // Iterate over the members dictionary and add them to the Group's member array
                // Used in Group Settings to show who is in the group
                for uid in members.keys {
                    let handle = members[uid]
                    
                    self.group.members.append(User(uid: uid, handle: handle!))
                }
                
                // Load the posts
                if let posts = value["posts"] as? [String : [String : Any]] {
                    for postID in posts.keys {
                        let timestamp = posts[postID]!["timestamp"] as! Double
                        //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                        let width = posts[postID]!["width"] as! Int
                        let height = posts[postID]!["height"] as! Int
                        
                        let post = Post(uid: postID, timestamp: timestamp)
                        post.setDimensions(width: width, height: height)
                        
                        // Simplt add it to the posts array
                        // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                        self.group.posts.append(post)
                    }
                    
                    // After loading in all of the posts, sort them
                    self.group.sortPosts()
                    
                    // Set how many posts to load, depending on how many we have
                    self.currentPostCount = self.group.posts.count
                    
                    // Done loading posts data, call completion with true, meaning posts have actually been loaded
                    completion(true)
                }
            } else {
                database.child("groups").child(group.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String : [String : Any]] {
                        for postID in value.keys {
                            let timestamp = value[postID]!["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = value[postID]!["width"] as! Int
                            let height = value[postID]!["height"] as! Int
                            
                            let post = Post(uid: postID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Simplt add it to the posts array
                            // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                            self.group.posts.append(post)
                        }
                        
                        // Save the post data after all of the posts are loaded
                        FileUtils.saveToJSON(dict: self.group.convertToDict(), toPath: "groups/\(self.group.uid).json")
                        
                        // After loading in all of the posts, sort them
                        self.group.sortPosts()
                        
                        // Set how many posts to load, depending on how many we have
                        self.currentPostCount = self.group.posts.count
                        
                        // Done loading posts data, call completion with true, meaning posts have actually been loaded
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        } else { // Posts count != 0
            // No posts needed to be loaded(as group.posts is not empty), so call completion as false
            completion(false)
        }
        
        completion(false)
    }
    
    // Process the JSON/database dictionary into post objects
    private func processPostData(dict: [String : Any]) {
    }
    
    func loadPostVideos(startIndex: Int, count: Int) {
        // Create the directory for the posts to be stored
        let documentDirectory = FileUtils.getDocumentsDirectory()
        let outputPath = "groups/\(group.uid)/posts"
        let outputURL = documentDirectory.appendingPathComponent(outputPath)
        
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        
        // Iterate through a range of posts
        for i in startIndex..<startIndex + count {
            let post = group.posts[i]
            
            let finalURL = outputURL.appendingPathComponent("\(post.uid).mp4")
            let finalPath = outputPath + "/\(post.uid).mp4"
            
            // Check if the file exists before trying to load it
            if FileUtils.doesFileExist(atPath: finalPath) { // Never works/always false
                print("Post loaded locally in \(group.name) with uid of \(post.uid)")
                post.filePath = finalPath
                
                // Update the according tableViewCell
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            
            } else { // File does not exist, load it from Firebase Storage
                print("Downloading post from Storage in group \(group.name) for post ID \(post.uid)")
                storage.child("groups").child(group.uid).child("posts").child(post.uid).write(toFile: finalURL, completion: { (url, error) in
                    if error == nil {
                        post.filePath = finalPath
                        
                        // Update the according tableViewCell once the post has been loaded
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                    } else {
                        print("ERROR LOADING POST VIDEO")
                        print(error?.localizedDescription as Any)
                        return
                    }
                })
            }
        }
    }
    
    // When we scroll down past a certain point, load more posts
    // Completion handler?
    func loadMorePosts() {
        var postDiff = group.posts.count - currentPostCount
        
        /*
        if postDiff > loadCount {
            postDiff = loadCount
        } */
        
        var indexPaths = [IndexPath]()
        // currentPostCount is a size(aka size of 1 = index of 0), so i starts at 0
        for i in 0..<postDiff {
            print("adding index \(currentPostCount + i) with UID of \(group.posts[currentPostCount + i].uid)")
            indexPaths.append(IndexPath(row: currentPostCount + i, section: 0))
        }
        
        currentPostCount += postDiff
        
        print(indexPaths)
        tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
        //tableView.reloadData()
        
        // Load more posts
        loadPostVideos(startIndex: currentPostCount - postDiff, count: postDiff)
    }
    
    // UploadPostDelegate function
    // Called in VideoPlaybackVC after the user has finalized the post
    func uploadPost(fileURL: URL) {
        // Generate a unique ID for this post
        let postID = database.child("groups").child(group.uid).child("posts").childByAutoId().key
        // Get the post upload time
        let timestamp = Date.timeIntervalSinceReferenceDate
        
        // Upload the post data to the database
        let postRef = database.child("groups").child(group.uid).child("posts").child(postID)
        //postRef.child("timestamp").setValue(timestamp)
        //postRef.child("poster").setValue(mainUser.uid)
        
        // Set the post dimensions in the database
        let dim = VideoUtils.resolutionForLocalVideo(url: fileURL)
        //postRef.child("width").setValue(Int((dim?.width)!))
        //postRef.child("height").setValue(Int((dim?.height)!))
        
        // Upload the video to Firebase Storage
        storage.child("groups").child(group.uid).child("posts").child(postID).putFile(from: fileURL)
        
        // Initialize the post
        let post = Post(uid: postID, timestamp: timestamp)
        post.filePath = fileURL.lastPathComponent
        
        post.setDimensions(width: Int((dim?.width)!), height: Int((dim?.height)!))
        
        postRef.setValue(post.convertToDict())
        
        // Add the post to the posts array in the current Group
        group.addPost(post: post)
        
        currentPostCount += 1
        
        // Insert it into the top of the tableView, shifting the other
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        // Resave the group json
        FileUtils.saveToJSON(dict: group.convertToDict(), toPath: "groups/\(group.uid).json")
    }
    
    // NewPostDelegate function
    func newPost(post: Post) {
        // Handle a post addition
        // Assuming it's already inserted into mainUser.groups.posts, simply insert the tableViewCell?
        
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        // Begin loading the video for the new post
        self.loadPostVideos(startIndex: 0, count: 1)
    }
    
    // Load the extra group data, mainly used in GroupSettings
    func loadExtraGroupData() {
        // This is loading in the posts data anyways
        database.child("groups").child(group.uid).observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let members = value["members"] as! [String: String]
                let creatorUID = value["creator"] as! String
                
                self.group.creatorUID = creatorUID
                
                // Iterate over the members dictionary and add them to the Group's member array
                // Used in Group Settings to show who is in the group
                if self.group.members.count == 0 { // Would add members each time we went into the Feed
                    for uid in members.keys {
                        let handle = members[uid]
                        
                        self.group.members.append(User(uid: uid, handle: handle!))
                    }
                }
                
                // Will save all of the data to the disk, every time
                //FileUtils.saveToJSON(dict: value, toPath: "groups/\(self.group.uid).json")
            }
        })
    }

    // Initilaizes observer for listening to new posts
    func addListeners() {
        postChangesHandle = database.child("groups").child(group.uid).child("posts").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                print(value)
                for newPostID in value.keys {
                    var isNewPost = true
                    
                    // Check if the newPostID is listed in group.posts
                    for oldPost in self.group.posts {
                        if newPostID == oldPost.uid { // If the newPostID matches an existing post ID
                            isNewPost = false // Then this isn't a new post, skip it
                        }
                    }
                    
                    // If this is a new post
                    if isNewPost {
                        print(value[newPostID])
                        if let data = value[newPostID] as? [String : Any] {
                            
                            let timestamp = data["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = data["width"] as! Int
                            let height = data["height"] as! Int
                            
                            let post = Post(uid: newPostID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Add it to the tableView and posts array
                            self.group.addPost(post: post)
                            
                            self.currentPostCount += 1
                            
                            DispatchQueue.main.async {
                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            }
                            
                            // Begin loading the video for the new post
                            self.loadPostVideos(startIndex: 0, count: 1)
                        }
                    }
                }
            }
        })
    }

    func removeListeners() {
        if let _ = postChangesHandle {
            database.removeObserver(withHandle: self.postChangesHandle)
        }
    }
}

// MARK: - Table View Functions
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! FeedTableViewCell
        
        cell.post = group.posts[indexPath.row]
        cell.initialize()
        
        //print("Init \(indexPath.row) \(cell.avPlayerLayer == nil)")
        
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "new") as! NewFeedTableViewCell
        
        */
        
        // Set up video URL
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return currentPostCount
        return group.posts.count
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
        
        // TODO: Determine what cell is in view
        // If the cell's center is in a certain range in the middle of the screen, play the video
        
        // Check if we've reached the bottom of the table
        if distanceFromBottom < height {
            // Add refresh control to the bottom
            // Wait til all of the posts are loaded, then add them to the tableView?
            
            // If so, start loading the other posts
            if currentPostCount < group.posts.count {
                //print("Loading more posts")
                //loadMorePosts()
            }
        }
    }
}

