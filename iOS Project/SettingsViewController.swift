//
//  SettingsViewController.swift
//  iOS Project
//
//  Created by Christine Berger on 12/4/17.
//  Copyright © 2017 Christine Berger. All rights reserved.
//
//  Notes:
//  Localized View

import UIKit    //UI element control

class SettingsViewController: UIViewController {
    
    //Elements to receive information from the UI.
    @IBOutlet weak var repeatSpellingToggle: UISwitch!
    @IBOutlet weak var randomizeSpellingToggle: UISwitch!
    @IBOutlet weak var repeatReadingToggle: UISwitch!
    @IBOutlet weak var randomizeReadingToggle: UISwitch!
    
    //Variable to manipulate UserDefault data.
    private var userDefaults = UserDefaults.standard
    
    /*=================================================================*
     * viewDidLoad()
     * Loads UI and performs other functions before appearing.
     *==================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    /*=================================================================*
     * viewDidAppear()
     * Sets up the view after it has been navigated to.
     *==================================================================*/
    override func viewDidAppear(_ animated: Bool) {
        //Set the toggle switch positions in the UI based on the user options
        //in User Default.
        repeatSpellingToggle.isOn = userDefaults.object(forKey: "Repeat Spelling") as! Bool
        randomizeSpellingToggle.isOn = userDefaults.object(forKey: "Random Spelling") as! Bool
        repeatReadingToggle.isOn = userDefaults.object(forKey: "Repeat Reading") as! Bool
        randomizeReadingToggle.isOn = userDefaults.object(forKey: "Random Reading") as! Bool
    }
    /*=================================================================*
     * setData()
     * Saves the options based on input from the UI.
     *==================================================================*/
    func setData(_ toggleBtn: UISwitch, _ key: String) {
        //Set the data in User Defaults to on or off depending on
        //the current state of the toggle button.
        if toggleBtn.isOn {
            userDefaults.set(true, forKey: key)
        } else {
            userDefaults.set(false, forKey: key)
        }
        
        //Save the options in User Defaults.
        userDefaults.synchronize()
    }
    /*=================================================================*
     * repeatSpellingToggled()
     * Handles the toggle action for repeating the word list in the
     * Spelling Exercise.
     *==================================================================*/
    @IBAction func repeatSpellingToggled(_ sender: Any) {
        //Save the chosen option in User Defaults
        setData(repeatSpellingToggle, "Repeat Spelling")
    }
    /*=================================================================*
     * randomizeSpellingToggled()
     * Handles the toggle action for shuffling the word list in the
     * Spelling Exercise.
     *==================================================================*/
    @IBAction func randomizeSpellingToggled(_ sender: Any) {
        //Save the chosen option in User Defaults
        setData(randomizeSpellingToggle, "Random Spelling")
    }
    /*=================================================================*
     * repeatReadingToggled()
     * Handles the toggle action for repeating the word list in the
     * Reading Exercise.
     *==================================================================*/
    @IBAction func repeatReadingToggled(_ sender: Any) {
        //Save the chosen option in User Defaults
        setData(repeatReadingToggle, "Repeat Reading")
    }
    /*=================================================================*
     * randomizeSpellingToggled()
     * Handles the toggle action for shuffling the word list in the
     * Reading Exercise.
     *==================================================================*/
    @IBAction func randomizeReadingToggled(_ sender: Any) {
        //Save the chosen option in User Defaults
        setData(randomizeReadingToggle, "Random Reading")
    }
}

