//
//  IntroViewController.swift
//  Uno
//
//  Created by Liam Kelly on 7/12/16.
//  Copyright © 2016 LiamKelly. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    var previousButton:UIButton?
    var opponents:Int!
    @IBOutlet weak var playButton:UIButton!

    
    override func viewDidLoad() {
        playButton.isEnabled = false
    }
    
    
    //MARK: Functions to edit selected button
    @IBAction func selectButton(_ sender: UIButton) {
        let num = sender.title(for: UIControlState())!
        edit(sender)
        switch num {
        case "1":
            opponents = 1
        case "2":
            opponents = 2
        case "3":
            opponents = 3
        default:
            opponents = 4
        }
        if let oldbutton = previousButton {
            let choice = oldbutton.title(for: UIControlState())
            if ((oldbutton.layer.cornerRadius == 5) && (choice != num)) {
                removeEdit(oldbutton)
            }
        }
        playButton.isEnabled = true
        previousButton = sender
    }
    
    func removeEdit(_ button: UIButton) {
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
        button.layer.borderColor = nil
    }
    
    func edit(_ button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    
    // MARK: Segue functions
    @IBAction func enterGame(_ sender: UIButton) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            vc.numberOfOpponents = self.opponents
            present(vc, animated: true, completion: nil)
    }
}
