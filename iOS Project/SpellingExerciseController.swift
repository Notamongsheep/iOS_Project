//
//  SpellingExerciseController.swift
//  iOS Project
//
//  NOTES:
//  Error in console (TTSPlaybackCreate unable to initialize dynamics: -3000):
//  At this time, the error does not affect the app. More can be read about this issue here:
//  https://forums.developer.apple.com/thread/87691
//  It seems to be a known issue that hasn't been addressed formally, with the fixes
//  varying based on the issues that occur within the app. As this app is working correctly,
//  troubleshooting this issue is not in the scope of the project at this time.
//
//  Created by Christine Berger on 12/4/17.
//  Copyright © 2017 Christine Berger. All rights reserved.


import UIKit                //Control UI Elements
import AVFoundation         //Control Audio
import GameplayKit          //To use the Random functions

class SpellingExerciseController: UIViewController, EndExerciseDelegate, AVSpeechSynthesizerDelegate {
   
    //Variable to control User Default data.
    private let userDefaults = UserDefaults.standard
    
    //Variables to hold options from User Defaults.
    private var wordList: [String] = []
    private var randomSpelling: Bool = false
    private var repeatSpelling: Bool = false
    
    //Elements to update the UI
    @IBOutlet weak var numWordsLeft: UILabel!
    @IBOutlet weak var numWordsLeftLabel: UILabel!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var practiceActivityView: UIView!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    //Screens to present when the exercise is over or there are no words.
    @IBOutlet weak var endExerciseView: UIView!
    @IBOutlet weak var noWordsView: UIView!
    
    //Elements that control the in-exercise feedback.
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupLabel: UILabel!
    
    //Element to control user input.
    @IBOutlet weak var answerField: UITextField!
    
    //Arrays that keep track of the randomized list or
    //the repeat once list (if skip is used, it's added to the end)
    private var randomizedWordList: [String] = []
    private var playOnceWordList: [String] = []
    
    //Array for color changing of replay audio button.
    private var buttonColors: [UIColor] = [ AppColor.Purple, AppColor.Pink, AppColor.Orange, AppColor.Blue ]
    
    //Variable to hold the current index position of the word arrays.
    private var currentWord = 0
    //Variable to hold the current color of the feedback items.
    private var currentColor = 0
    
    //Flag for an ended exercise session.
    private var gameEnded:Bool = false

    //Variables needed for controlling voice over.
    private var utterance = AVSpeechUtterance()
    private let synthesizer = AVSpeechSynthesizer()
    
    /*=================================================================*
     * viewDidLoad()
     * Prepare the session.
     *==================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the voice over voice.
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        //Disable predictive text
        answerField.autocorrectionType = .no
    }
    /*=================================================================*
     * viewDidAppear()
     * Re-initialize things if the user navigates away and then comes back.
     *==================================================================*/
    override func viewDidAppear(_ animated: Bool) {
        
        //Stop the loading indicator
        loadingIcon.stopAnimating()
        
        //Initialize the exercise.
        if initializeExercise() {
            //Say the current word.
            saySpellCurrentWord()
        }
            
    }
    /*=================================================================*
     * viewDidDisappear()
     * Stop processes when the user navigates away.
     *==================================================================*/
    override func viewDidDisappear(_ animated: Bool) {
        synthesizer.stopSpeaking(at: .immediate)
        answerField.text = ""
    }
    /*=================================================================*
     * prepare(forSegue)
     * Give control of the child view to this view.
     *==================================================================*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EndExerciseViewController {
            destination.delegate = self
        }
    }
    /*=================================================================*
     * initializeExercise()
     * Put everything back to it's initial state.
     *==================================================================*/
    @discardableResult func initializeExercise()->Bool {
        
        //Get the most current data.
        getData()
        
        //Set the current word to the first word.
        currentWord = 0
        
        //Set the flag for an ended game to false.
        gameEnded = false
        
        //If there are words in the list:
        if !wordList.isEmpty {
            //Update the UI to show the number of words left.
            showWordsLeft()
            
            //Only hide other views if they are showing.
            if !endExerciseView.isHidden {
                endExerciseView.isHidden = true
            }
            if !noWordsView.isHidden {
                noWordsView.isHidden = true
            }
            //Show the activity if it is hidden.
            if practiceActivityView.isHidden {
                practiceActivityView.isHidden = false
            }
            
            //If random words is turned on, shuffle the array.
            if randomSpelling {
                randomizedWordList = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: wordList) as! [String]
            }
            
            //Show the number of words left.
            showWordsLeft()
           
            //Put the cursor in the textfield.
            answerField.becomeFirstResponder()
            
            return true
            
        //If there are no words in the list:
        } else {
            practiceActivityView.isHidden = false
            
            //Only show the 'No Words' message if it isn't already showing.
            if noWordsView.isHidden {
                noWordsView.isHidden = false
            }
            
            return false
        }
    }
    /*=================================================================*
     * getData()
     * Get the current data from UserDefaults.
     *==================================================================*/
    func getData() {
        wordList = userDefaults.object(forKey: "Sight Words") as! [String]
        playOnceWordList = wordList
        randomSpelling = userDefaults.object(forKey: "Random Spelling") as! Bool
        repeatSpelling = userDefaults.object(forKey: "Repeat Spelling") as! Bool
    }
    /*=================================================================*
     * saySpellCurrentWord()
     * Say the word "Spell" before the current word.
     *==================================================================*/
    func saySpellCurrentWord() {
        speak("Spell")
        speakCurrentWord()
    }
    /*=================================================================*
     * replayVoiceOver()
     * Only say the current word on button press.
     *==================================================================*/
    @IBAction func replayVoiceOver(_ sender: Any) {
        speakCurrentWord()
    }
    /*=================================================================*
     * speakCurrentWord()
     * Say the current word based on the settings (random or not)
     *==================================================================*/
    func speakCurrentWord() {
        //If random is on:
        if randomSpelling {
            speak(randomizedWordList[currentWord])
        } else {
            speak(playOnceWordList[currentWord])
        }
    }
    /*=================================================================*
     * speak()
     * Say the message that is sent into this function.
     *==================================================================*/
    func speak(_ message: String) {
        //Initialize utterance with a new message.
        utterance = AVSpeechUtterance(string: message)
        //Tell the controller to play the utterance.
        synthesizer.speak(utterance)
    }
    /*=================================================================*
     * compareWords()
     * Check the answer to see if it matches the word in the array.
     *==================================================================*/
    func compareWords(_ array: [String])->Bool {
        //Variable that holds the given answer without leading and trailing whitespace.
        let tempAnswer = answerField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        //If the answer is the same as the current word:
        if tempAnswer == array[currentWord] {
            return true
        } else {
            return false
        }
    }
    /*=================================================================*
     * isAnswerCorrect()
     * Find out if the answer given is correct.
     *==================================================================*/
    func isAnswerCorrect()->Bool {
        //Temporary bool to hold the result.
        var wordMatches:Bool = false
        
        //Check if the answer matches the word in the associated array
        //Based on whether random is on or off.
        if randomSpelling {
            wordMatches = compareWords(randomizedWordList)
        } else {
            wordMatches = compareWords(playOnceWordList)
        }
        
        return wordMatches
    }
    /*=================================================================*
     * showFeedback()
     * Change the UI and play audio for feedback.
     *==================================================================*/
    func showFeedback(_ result: Bool) {
        //Temporary variable to hold a message.
        var message = ""
        //Change the UI colors and message to play to the user.
        if result {
            numWordsLeft.textColor = AppColor.ThemeDark
            popupView.backgroundColor = AppColor.ThemeDark
            message = "Good Job!"
        } else {
            numWordsLeft.textColor = AppColor.ThemeNegative
            popupView.backgroundColor = AppColor.ThemeNegative
            message = "Try Again"
        }
        //Show the feedback popup and play the message.
        popupLabel.text = message
        popupView.isHidden = false
        speak(message)
    }
    /*=================================================================*
     * showWordsLeft()
     * Update the UI to show the amount of words left.
     *==================================================================*/
    func showWordsLeft() {
        //Update the remaining words displayed to the user.
        let remainingWords = wordList.count - currentWord
        
        //Get a random color for the 'words left' display,
        //repeat shuffle if the color is the same as before.
        repeat {
            currentColor = Int(arc4random_uniform(UInt32(buttonColors.count)))
        } while replayButton.backgroundColor == buttonColors[currentColor]
        
        //Set the colors of the UI to indicate a new question has been set.
        replayButton.backgroundColor = buttonColors[currentColor]
        numWordsLeft.textColor = buttonColors[currentColor]
        
        //Show the number of words left to spell.
        numWordsLeft.text = String("\(remainingWords)")
        
        //Use singular form of words for 1 element.
        if currentWord == wordList.count - 1 {
            numWordsLeftLabel.text = "word left"
        } else {
            numWordsLeftLabel.text = "words left"
        }
    }
    /*=================================================================*
     * nextQuestion()
     * Go to the next word if applicable and call updates to the UI.
     *==================================================================*/
    func nextQuestion() {
        
        //If there are still words left:
        if currentWord < wordList.count - 1 {
            //Go to the next word
            currentWord += 1
            
            //Update the UI to show the amount of remaining words.
            showWordsLeft()
        } else {
            //Repeat the exercise if repeat is on.
            if repeatSpelling {
                initializeExercise()
            } else {
                //Send a message that the game has ended.
                gameEnded = true
            }
        }
    }
    /*=================================================================*
     * checkAnswer()
     * Say the current word based on the settings (random or not)
     *==================================================================*/
    @IBAction func checkAnswer(_ sender: Any) {
        //Check the answer and show feedback.
        let isCorrect = isAnswerCorrect()
        showFeedback(isCorrect)
        //Clear the input field.
        answerField.text = ""
        //Wait a second for the audio and visual feedback to finish,
        //then end the game or play the next question.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //Hide the popup.
            self.popupView.isHidden = true
            
            if isCorrect {
                self.nextQuestion()
            } else {
                self.numWordsLeft.textColor = self.buttonColors[self.currentColor]
            }
            
            if !self.gameEnded {
                //Say the current word.
                self.saySpellCurrentWord()
                self.answerField.becomeFirstResponder()
            } else {
                //Hide the activity view and show the end game controller.
                self.practiceActivityView.isHidden = true
                self.endExerciseView.isHidden = false
            }
        }
    }
    /*=================================================================*
     * restartButtonPressed()   EndExerciseDelegate Method
     * Restart the game from embedded view controller.
     *==================================================================*/
    func restartButtonPressed() {
        viewDidAppear(true)
    }
    /*=================================================================*
     * skipWord()
     * Skip the word and put it in the back of the array.
     *==================================================================*/
    @IBAction func skipWord(_ sender: Any) {
        //Stop the synthesizer if it is speaking.
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        //If the exercise is not in random mode.
        if !randomSpelling {
            playOnceWordList = pushToBack(playOnceWordList)
        } else {
            randomizedWordList = pushToBack(randomizedWordList)
        }
        
        //Go to the next question.
        nextQuestion()
        
        //Clear the answer field.
        answerField.text = ""
        
        //Speak the current word.
        saySpellCurrentWord()
    }
    /*=================================================================*
     * pushToBack()
     * Puts the current work on the end of the array.
     *==================================================================*/
    func pushToBack(_ array: [String])->[String] {
        //Temporarily hold the current word.
        let tempWord = array[currentWord]
        //Temporary array to hold the array contents.
        var tempArray = array
        //Remove the current word from the list.
        tempArray.remove(at: currentWord)
        //Add the word to the end of the list.
        tempArray.append(tempWord)
        //Go back one word so that next question outputs the correct word.
        currentWord = currentWord - 1
        //Return the temporary array
        return tempArray
    }
}
