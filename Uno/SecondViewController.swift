//
//  SecondViewController.swift
//  Uno
//
//  Created by Liam Kelly on 7/6/16.
//  Copyright © 2016 LiamKelly. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var scrollView:UIScrollView!
    var image = UIImageView()
    let array = ["1","2","3","4","5"]
    let num = 4
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        scrollView.alwaysBounceHorizontal = true
        scrollView.pagingEnabled = true
        image.userInteractionEnabled = true
        
        for _ in 0...num {
            let image = UIImageView()
            image.image = UIImage(named: array[index])
            image.frame = CGRectMake(<#T##CGFloat#>, <#T##CGFloat#>, <#T##CGFloat#>, <#T##CGFloat#>)
            scrollView.addSubview(image)
            index+=1
        }
    }
    
}
