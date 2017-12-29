//
//  EndExerciseViewController.swift
//  iOS Project
//
//  Created by Christine Berger on 12/7/17.
//  Copyright © 2017 Christine Berger. All rights reserved.
//

import UIKit    //Helps handle UI functionality.

class EndExerciseViewController: UIViewController {
    
    //Provides a delegate member to hand over control.
    weak var delegate: EndExerciseDelegate?
    
    //Loads view.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Executes restatButtonPressed() from whichever controller took over delegating.
    @IBAction func restartExercise(_ sender: UIButton) {
        delegate?.restartButtonPressed()
    }
}
