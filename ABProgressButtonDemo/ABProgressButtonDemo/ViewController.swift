//
//  ViewController.swift
//  ABProgressButtonDemo
//
//  Created by Alex Bakhtin on 8/10/15.
//  Copyright © 2015 bakhtin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressButton: ABProgressButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func progressButtonAction(sender: AnyObject) {

        self.progressButton.progressState = self.progressButton.progressState == .Progressing ? .Default : .Progressing
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.progressButton.progress = 0.2
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.progressButton.progress! += 0.2
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.progressButton.progress! += 0.3
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.progressButton.progress = 1.0

                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.progressButton .setTitle("Dowloaded", forState: UIControlState.Normal)
                            self.progressButton.progressState = .Default
                        }
                    }
                }
            }
        }
    }

}

