//
//  ReadingExerciseController.swift
//  iOS Project
//
//  Created by Christine Berger on 12/4/17.
//  Copyright © 2017 Christine Berger. All rights reserved.
//

import UIKit            //Control UI Elements
import GameplayKit      //Used for Random function

class ReadingExerciseController: UIViewController, EndExerciseDelegate {
    
    //Keeps track of the current word.
    private var currentIndex = 0
    
    
    //User Defaults controller to access data.
    private var userDefaults = UserDefaults.standard
    
    //Variables to store user default options.
    private var repeatReading: Bool = false
    private var randomReading: Bool = false
    private var wordList: [String] = []
    
    //Used to keep track of the shuffled wordlist.
    private var shuffledWordList: [String] = []
    
    //Elements to manipulate the UI.
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var endExerciseView: UIView!
    
    /*=================================================================*
     * viewDidLoad()
     * Perform actions before displaying the UI.
     *==================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    /*=================================================================*
     * viewDidAppear()
     * Initialize the exercise when view appears.
     *==================================================================*/
    override func viewDidAppear(_ animated: Bool)  {
        getData()
        initializeExercise()
    }
    /*=================================================================*
     * prepare(for segue)
     * Control the destination view from this view controller.
     *==================================================================*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Control the destination view from this view controller on segue.
        if let destination = segue.destination as? EndExerciseViewController {
            destination.delegate = self
        }
    }
    /*=================================================================*
     * getData()
     * Get the current data from UserDefaults.
     *==================================================================*/
    func getData() {
        repeatReading = userDefaults.object(forKey: "Repeat Reading") as! Bool
        randomReading = userDefaults.object(forKey: "Random Reading") as! Bool
        wordList = userDefaults.object(forKey: "Sight Words") as! [String]
    }
    /*=================================================================*
     * initializeExercise()
     * Set exercise defaults.
     *==================================================================*/
    func initializeExercise() {
        
        //Set the current word to the first word.
        currentIndex = 0
        
        //If the wordlist has words:
        if !wordList.isEmpty {
            //Hide the 'No Items' and end game views if they are showing.
            if !noItemsView.isHidden {
                noItemsView.isHidden = true
            }
            if !endExerciseView.isHidden {
                noItemsView.isHidden = true
            }
            
            //Setup the words based on the user settings.
            //If 'random words' is on:
            if randomReading {
                //Shuffle the wordList array.
                shuffledWordList = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: wordList) as! [String]
            }
            
            //Show the first word
            showWord()
            
            //Otherwise, there are no words:
        } else {
            //Show the 'No Items' view.
            noItemsView.isHidden = false
        }
    }
    /*=================================================================*
     * nextCard()
     * Shows the next card.
     *==================================================================*/
    @IBAction func nextCard(_ sender: Any) {
        //Get the next index of the word list array.
        currentIndex += 1
        
        //If the wordlist still has words that were not shown:
        if currentIndex < wordList.count {
            showWord()
        //Otherwise, repeat or end the exercise.
        } else {
            if repeatReading {
                initializeExercise()
            } else {
                endExerciseView.isHidden = false
            }
        }
    }
    /*=================================================================*
     * showWord()
     * Show the current word in the UI.
     *==================================================================*/
    func showWord() {
        //If random is on, get the word from the shuffled array.
        if randomReading {
            wordLabel.text = shuffledWordList[currentIndex]
        //Otherwise, get it from the original array.
        } else {
            wordLabel.text = wordList[currentIndex]
        }
    }
    /*=================================================================*
     * restartButtonPressed()           EndGameDelegate Method
     * Restarts the exercise.
     *==================================================================*/
    func restartButtonPressed() {
        //Hide the end exercise view.
        endExerciseView.isHidden = true
        //Re-initialize the exercise.
        initializeExercise()
    }
}

