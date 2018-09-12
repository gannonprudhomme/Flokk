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

class FeedViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    var group: Group! // Need to move this to a Controller?
    
    var leaveGroupDelegate: LeaveGroupDelegate! // Used by GroupSettingsVC
    var postChangesHandle: UInt! // Need to move this(listening) to a Controller?
    
    init() {
        super.init(node: ASTableNode())
    }
    
    // Do any view access in here, but no layout code
    override func viewDidLoad() {
        navigationItem.title = group.name
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "groupIconTeal"), style: .plain, target: self, action: #selector(self.goToGroupSettings))
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor(named: "Flokk Navy")
        
        
        // Load all of the post videos
        // This is assuming the data for this group has already been loaded
        loadPostVideos(startIndex: 0, count: group.posts.count)
        
        // Begin listening for new posts
        addListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Set the group's feed delegate to nil, notifying it that its respective Feed is not in view anymore
        group.feedDelegate = nil
        
        // Stop the new posts listener
        removeListeners()
        
        // Stop the videos from being played after we segue out
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func addPostPressed(_ sender: Any) {
        performSegue(withIdentifier: "feedToCameraSegue", sender: nil)
    }
    
    @objc func goToGroupSettings() {
        let groupSettingsVC = UIStoryboard(name: "Groups", bundle: nil).instantiateViewController(withIdentifier: "GroupSettingsViewController") as! GroupSettingsViewController
        
        groupSettingsVC.group = group
        groupSettingsVC.leaveGroupDelegate = leaveGroupDelegate
        
        navigationController?.pushViewController(groupSettingsVC, animated: true)
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

// TODO: Move this out of the VC
// MARK: - Table Node Functions
extension FeedViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let post = group.posts[indexPath.row]
        let node = FeedTableCell(post: post)
        
        return node
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return group.posts.count
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
}


// TODO: Move this to a Controller
// MARK: - Post Handling
extension FeedViewController: UploadPostDelegate, NewPostDelegate {
    func loadPostVideos(startIndex: Int, count: Int) {
        // Create the directory for the posts to be stored
        let outputPath = "groups/\(group.uid)/posts"
        let outputURL = FileUtils.getDocumentsDirectory().appendingPathComponent(outputPath)
        
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        
        // Iterate through a range of posts
        for i in startIndex..<startIndex + count {
            let post = group.posts[i]
            //print(post)
            
            let finalURL = outputURL.appendingPathComponent("\(post.uid).mp4")
            let finalPath = outputPath + "/\(post.uid).mp4"
            
            // Check if the file exists before trying to load it
            if FileUtils.doesFileExist(atPath: finalPath) { // Never works/always false
                //print("Post loaded locally in \(group.name) with uid of \(post.uid)")
                post.filePath = finalPath
                
                self.tableNode.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
                // Update the according tableViewCell
                DispatchQueue.main.async {
                    //self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            
            } else { // File does not exist, load it from Firebase Storage
                print("Downloading post from Storage in group \(group.name) for post ID \(post.uid)")
                storage.child("groups").child(group.uid).child("posts").child(post.uid).write(toFile: finalURL, completion: { (url, error) in
                    if error == nil {
                        post.filePath = finalPath
                        
                        self.tableNode.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        
                        // Update the according tableViewCell once the post has been loaded
                        DispatchQueue.main.async {
                            
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
    
    func loadPosterIcons(startIndex: Int, count: Int) {
        // Could also split the posts into maps [String memberUID : Array of post UIDS]
        // And after loading the member's profile picture, reload all of the posts that that specific user uploaded
        // This would mean we would have to split the posts after we've loaded them in into these subgroups, before acting upon them
        
        // For every post to load poster icons for
            // Check if the user with that UID is loaded in already
                // If they are, check if
            // If not, completely load them
        
        
        for i in startIndex..<(startIndex + count) {
            
        }
    }
    
    // UploadPostDelegate function
    // Called in VideoPlaybackVC after the user has finalized the post
    func uploadPost(fileURL: URL) {
        // Generate a unique ID for this post
        let postID = database.child("groups").child(group.uid).child("posts").childByAutoId().key
        // Get the post upload time
        let timestamp = Date.timeIntervalSinceReferenceDate
        
        // Set the post dimensions in the database
        let dim = VideoUtils.resolutionForLocalVideo(url: fileURL)
        
        // Upload the video to Firebase Storage
        storage.child("groups").child(group.uid).child("posts").child(postID).putFile(from: fileURL)
        
        // Initialize the post
        let post = Post(uid: postID, timestamp: timestamp)
        post.filePath = fileURL.lastPathComponent
        
        post.setDimensions(width: Int((dim?.width)!), height: Int((dim?.height)!))
        
        // Upload the post data to the database all at once
        // Has to be a "batch" upload due to listeners attempting to load the new post data when it's not fully uploaded
        database.child("groups").child(group.uid).child("posts").child(postID).setValue(post.convertToDict())
        
        // Add the post to the posts array in the current Group
        group.addPost(post: post)
        
        // TODO: Update the according group cell in the tableView?
        
        // Insert it into the top of the tableView, shifting the other
        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        // Resave the group json
        FileUtils.saveToJSON(dict: group.convertToDict(), toPath: "groups/\(group.uid)/data.json")
    }
    
    // NewPostDelegate function
    func newPost(post: Post) {
        // Handle a post addition
        // Assuming it's already inserted into mainUser.groups.posts, simply insert the tableViewCell
        
        DispatchQueue.main.async {
            //self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        // Begin loading the video for the new post
        self.loadPostVideos(startIndex: 0, count: 1)
    }
    
    // Initilaizes observer for listening to new posts
    func addListeners() {
        postChangesHandle = database.child("groups").child(group.uid).child("posts").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
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
                        if let data = value[newPostID] as? [String : Any] {
                            
                            let timestamp = data["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = data["width"] as! Int
                            let height = data["height"] as! Int
                            
                            let post = Post(uid: newPostID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Add it to the tableView and posts array
                            self.group.addPost(post: post)
                            
                            DispatchQueue.main.async {
                                //self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            }
                            
                            // Begin loading the video for the new post
                            self.loadPostVideos(startIndex: 0, count: 1)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
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

