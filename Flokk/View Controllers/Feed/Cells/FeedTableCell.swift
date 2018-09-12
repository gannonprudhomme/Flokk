//
//  FeedTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation

class FeedTableCell: ASCellNode {
    var videoNode: ASVideoNode! // Video player
    var userIcon: ASNetworkImageNode! // User's profile photo
    var text: ASTextNode!
    
    var post: Post // Link to the
    
    init(post: Post) {
        self.post = post
        super.init()
        
        self.backgroundColor = UIColor(named: "Flokk Navy")
        
        // Initialize the video node
        videoNode = ASVideoNode()
        videoNode.delegate = self
        videoNode.shouldAutorepeat = true
        videoNode.backgroundColor = UIColor(named: "Flokk Navy")
        
        // Calculate the aspectRatio, to determine how tall the video needs to be
        let aspectRatio: CGFloat = CGFloat(post.dimensions!.width!) / CGFloat(post.dimensions!.height!)
        let fullWidth = UIScreen.main.bounds.width
        
        // Set the appropriate size for the video(and thus the cell)
        videoNode.style.preferredSize = CGSize(width: fullWidth, height: fullWidth / aspectRatio)
        self.addSubnode(videoNode)
        
        // If the video is loaded in
        if let path = post.filePath {
            // Assign the video to the videoNode
            videoNode.asset = AVAsset(url: post.getFileURL()!)
        }
    }

    override func didLoad() {}
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = UIEdgeInsetsMake(0, 0, 40, 0)
        let insetLayout = ASInsetLayoutSpec(insets: insets, child: videoNode)
        
        let layout = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [ insetLayout ])
        
        return layout
    }
}

extension FeedTableCell: ASVideoNodeDelegate {
    func didTap(_ videoPlayer: ASVideoPlayerNode) {
        if videoNode.playerState == .playing {
            videoNode.pause()
        } else {
            videoNode.play()
        }
    }
}
