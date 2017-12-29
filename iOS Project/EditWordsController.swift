//
//  ThirdViewController.swift
//  iOS Project
//
//  Created by Christine Berger on 12/4/17.
//  Copyright © 2017 Christine Berger. All rights reserved.
//

import UIKit    //Control UI Elements

class EditWordsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //Variable to manipulate user defaults.
    private let userDefaults = UserDefaults.standard
    
    //Data to store the table view list items.
    private var data: [String] = []
    //Data to delete from the list items.
    private var deleteData: [Int] = []
    //Table View object
    @IBOutlet weak var tableView: UITableView!
    //Button for the tableview's navigation controller
    private var editButton: UIBarButtonItem = UIBarButtonItem()
    //Array of bar button items to add to the nav controller.
    private var barButtonItems: [UIBarButtonItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load array from local storage.
        data = userDefaults.object(forKey: "Sight Words") as! [String]
        
        //Set the edit bar button and define the function that will use it.
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItems))
        
        //Define the cancel and delete buttons (for when edit is clicked)
        //and the functions that will control them.
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItems))
        
        //Add the bar buttons to the bar button array.
        barButtonItems.append(cancelButton)
        barButtonItems.append(deleteButton)
        
        //Set the right nav to hold the edit button.
        self.navigationItem.rightBarButtonItem = editButton
        
        //Set the table view's delegate and data source to this view controller.
        tableView.dataSource = self
        tableView.delegate = self
 
    }
    /*=================================================================*
     * tableView()  Number Of Rows In Section
     * Defines the number of rows in each table view section.
     *==================================================================*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count   //Give the number of data items.
    }
    /*=================================================================*
     * tableView()  Cell For Row At
     * Defines the UI for the cells of the the table
     *==================================================================*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Reference the cell ID to manipulate it.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")!
        //Set the text to the current data item's text.
        let text = data[indexPath.row]
        cell.textLabel?.text = text
        //Set the font size
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        //Return the modified cell style.
        return cell
    }
    /*=================================================================*
     * numberOfSections()
     * Defines the number of sections in the table view.
     *==================================================================*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*=================================================================*
     * tableView()  Did Select Row At
     * Handles the selection of a table view row (A cell has been tapped)
     *==================================================================*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If the table is in edit mode when there was an item tap:
        if tableView.isEditing {
            //Add the index of the cell that was clicked to the deleteData array.
            deleteData.append(indexPath.row)
            //Add the delete option only when there is at least one item selected.
            //Do not perform this every time, this is why we only check for one item.
            if deleteData.count == 1 {
                //Remove any current buttons and add the array of buttons (delete and cancel)
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.rightBarButtonItems = barButtonItems
            }
        //If the table is not in edit mode when there was an item tap:
        } else {
            
            //Define a new alert to rename the item tapped.
            let alert = UIAlertController (
                title: "Rename Item",
                message: "Enter the new name for \'" + data[indexPath.row] + "\':",
                preferredStyle: .alert)
            
            // Add a text field to the alert for renaming the item.
            alert.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                //Set the textfield's delegate to this controller.
                textField.delegate = self
            })
            
            //Add a cancel button to the alert.
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            //Add a confirmation button to the alert.
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (_) in
                /** Use the handler to rename when this button is clicked. **/
                //use a variable to hold the textfield text, getting rid of whitespaces.
                let newData = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces)
                //If there is text entered in the field:
                if !newData!.isEmpty {
                    //Save over the item in the array with the new text.
                    self.data[indexPath.row] = newData!
                    //Save over the data set in User Defaults with the modified data array.
                    self.userDefaults.set(self.data, forKey:"Sight Words")
                    self.userDefaults.synchronize()
                    //Reload the table view list items.
                    self.tableView.reloadData()
                }
            }))
            
            //Show the alert to the user.
            self.present(alert, animated: true, completion: nil)
        }
    }
    /*=================================================================*
     * tableView()  Did Deselect Row At
     * Handles the DEselection of a table view row (A cell has been
     * tapped again to deselect it)
     *==================================================================*/
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //Use filter to resave the deleteData indexes without the deselected row.
        //(In other words, remove without having to cycle through the array)
        deleteData = deleteData.filter { $0 != indexPath.row }
        //If deleting the item above created an empty array:
        if deleteData.isEmpty {
            //Only show the cancel button in the right of the nav.
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = barButtonItems[0]
        }
    }
    /*=================================================================*
     * textField()  Should Change Characters In
     * Handles input when there is a change in the textfield.
     *==================================================================*/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Variable to hold the max number of characters.
        let maxLength = 128
        
        //Ensure that the textfield character length does not exceed the maxLength of characters.
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= maxLength
    }
    /*=================================================================*
     * addItems()
     * Add an item to the word list.
     *==================================================================*/
    @IBAction func addItems(_ sender: Any) {
        //Define an alert box.
        let alert = UIAlertController(
            title: "New Word",
            message: "Insert the new word:",
            preferredStyle: .alert)
        
        //Add a text field to the alert box for the new item.
        alert.addTextField(configurationHandler: nil)
        
        //Add a cancel button.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Add an 'Add' button.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            //Variable to hold the new item text, without whitespaces.
            let newData = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces)
            //If the textfield was not empty:
            if !newData!.isEmpty
            {
                //Add the new item to the data array.
                self.data.append(newData!)
                //Replace the data array in user defaults with the modified version and save.
                self.userDefaults.set(self.data, forKey:"Sight Words")
                self.userDefaults.synchronize()
                //Reload the table view list items.
                self.tableView.reloadData()
            }
        }))
        
        //Show to alert to the user.
        self.present(alert, animated: true, completion: nil)
    }
    /*=================================================================*
     * editItems()
     * Handles tap of the edit button in the nav controller.
     *==================================================================*/
    @objc func editItems(_ sender: UIBarButtonItem) {
        //Set the table view editing mode to on.
        self.tableView.isEditing = true
        //Set the initial right nav button to cancel.
        self.navigationItem.rightBarButtonItem = barButtonItems[0]
    }
    /*=================================================================*
     * deleteItems()
     * Handles tap of the delete button in the nav controller.
     *==================================================================*/
    @objc func deleteItems(_ sender: UIBarButtonItem) {
        //Define a new alert.
        let alert = UIAlertController(
            title: "Delete Words",
            message: "Are you sure you want to delete the selected words?",
            preferredStyle: .alert)
        
        //Add a cancel button.
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        //Add an confirm button.
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                //Sort the deleteData indices from highest to lowest -
                //This ensures that the items stay in place and that the correct items
                //are deleted with each delete operation.
                self.deleteData = self.deleteData.sorted { $0 > $1 }
                //Delete each item using the data from deleteData as the index of the data array.
                for index in self.deleteData {
                    self.data.remove(at: index)
                }
                //Clear the deleteData array for reuse.
                self.deleteData.removeAll()
                //Replace the data array in user defaults with the modified version and save.
                self.userDefaults.set(self.data, forKey:"Sight Words")
                self.userDefaults.synchronize()
                //Reload the table view list items.
                self.tableView.reloadData()
        }))
        
        //Show the alert to the user.
        self.present(alert, animated: true, completion: nil)
    }
    /*=================================================================*
     * cancelEdit()
     * Handles tap of the cancel button in the nav controller.
     *==================================================================*/
    @objc func cancelEdit(_ sender: UIBarButtonItem) {
        //Turn off table editing mode.
        self.tableView.isEditing = false
        //Get rid of the editing buttons (delete and cancel) and add the edit button.
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = editButton
    }
}

