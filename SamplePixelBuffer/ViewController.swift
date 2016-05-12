//
//  ViewController.swift
//  SamplePixelBuffer
//
//  Created by SeoDongHee on 2016. 5. 12..
//  Copyright © 2016년 SeoDongHee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    var image: UIImage!
    var path: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        image = UIImage.init(named: "test.png")
        imageview.image = image
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btn1Pressed(sender: AnyObject) {
        let imagestovideo = ImagesToVideo(sender: self)
        imagestovideo.pixelBufferFromImage(self.image)
    }

}

