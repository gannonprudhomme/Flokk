//
//  OpenViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 8/23/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import SwiftVideoBackground

class OpenViewController: UIViewController {
    @IBOutlet var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? VideoBackground.shared.play(view: videoView, videoName: "myVideo", videoType: "mp4")
        
        /* or from URL */
        
        //let url = URL(string: "https://coolVids.com/coolVid.mp4")!
        //VideoBackground.shared.play(view: videoView, url: url)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Light content status bar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
