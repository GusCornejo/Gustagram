//
//  LoginViewController.swift
//  Gustagram
//
//  Created by Gustavo Cornejo on 10/6/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testParseConnection()
        hidesKeyboard()
    }
    
    func hidesKeyboard() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func testParseConnection(){
           let myObj = PFObject(className:"FirstClass")
           myObj["message"] = "Hey ! First message from Swift. Parse is now connected"
           myObj.saveInBackground { (success, error) in
               if(success){
                   print("You are connected!")
               }else{
                   print("An error has occurred!")
               }
           }
       }
    
    @IBAction func onSignIn(_ sender: Any) {
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { user, error in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { success, error in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    
}
