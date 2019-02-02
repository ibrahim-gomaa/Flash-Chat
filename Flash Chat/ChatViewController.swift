
//  ViewController.swift
//  Flash Chat
//
//  Created by ibrahim 29/12/2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]()

    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped) )
        messageTableView.addGestureRecognizer(tapGesture)
        
        //MARK:- Register your MessageCell.xib file
        messageTableView.register(UINib (nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configrationTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none
    }
    
    //MARK:- Table view delgete methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email{
            cell.avatarImageView.backgroundColor = UIColor.flatGreen()
        } else  {
            cell.avatarImageView.backgroundColor = UIColor.flatPowderBlue()
            cell.messageBackground.backgroundColor = UIColor.flatWatermelon()
            
        }
        
        return cell
    }
    

  
    //Declare tableViewTapped
    @objc func tableViewTapped () {
        messageTextfield.endEditing(true)
    }
    
    //Declare configureTableView
    func configrationTableView () {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    //Declare textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 350
            self.view.layoutIfNeeded()
        }
    }
 
    //MARK:- Declaring textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        
    }
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        sendButton.isEnabled = false
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["sender": Auth.auth().currentUser?.email, "messageBody": messageTextfield.text]
        messageDB.childByAutoId().setValue(messageDictionary){
            (error , refrence) in
            if error != nil{
                print("there is an error:\(error!)")
            }
            else{
                print("Message saved")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
               
            }
            
        }
        
    }
    
    
//    MARK:- Create the retrieveMessages method
    func retrieveMessages () {
        
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append (message)
            self.configrationTableView()
            self.messageTableView.reloadData()
            
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //MARK:- Log out methods
        do {
        try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Erorr")
        }
    }
    


}
 
