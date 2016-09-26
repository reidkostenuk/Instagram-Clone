/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpOrLogin: UIButton!
    @IBOutlet weak var changeSignUpModeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var signUpMode = true
    var activityIndicator = UIActivityIndicatorView()
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func SignUpOrLogin(_ sender: AnyObject) {
        
        // if there is nothing in the text fields then create alert.
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            createAlert(title: "Error in form", message: "Please enter an email and password")
            
        // if there is something in the text fields then let's do something with it.
        } else {
            
            // create activity indicator and freeze screen so that user cannot interfere.
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if signUpMode {
                
                // Sign up mode - create a new user by assigning appropriate variables.
                let user = PFUser()
                user.username = emailTextField.text
                user.email = emailTextField.text
                user.password = passwordTextField.text
                
                user.signUpInBackground(block: { (success, error) in
                    
                    // stop activity indicator once signed up
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // if there is an error signing up user then display error.
                    if error != nil {
                        
                        var displayErrorMessage = "Please try again later."
                        
                        if (error as? NSError) != nil {
                            print(error)
                            
                            if let errorMessage = (error as? NSError)?.userInfo["error"] as? String {
                                
                                displayErrorMessage = errorMessage
                            }
                        }
                        
                        self.createAlert(title: "Log In Error", message: displayErrorMessage)
                        
                    // if there is no error then perform segue
                    } else {
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
                
            } else {
                
                // Log In mode - find info in background
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // if there is an error then display message in alert.
                    
                    if error != nil {
                        
                        var displayErrorMessage = "Please try again later."
                        
                        if (error as? NSError) != nil {
                            print(error)
                            
                            if let errorMessage = (error as? NSError)?.userInfo["error"] as? String {

                                displayErrorMessage = errorMessage
                            }
                        }
                        
                        self.createAlert(title: "Log In Error", message: displayErrorMessage)
                        
                    // if there is no error then perform segue.
                    } else {
                    
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
            }
        }
    }
    
    @IBAction func changeSignUpModeButton(_ sender: AnyObject) {
        
        if signUpMode {
            
            // Change to log in mode
            signUpOrLogin.setTitle("Log In", for: [])
            changeSignUpModeButton.setTitle("Sign Up", for: [])
            messageLabel.text = "Don't have an account?"
            signUpMode = false
            
        } else {
            
            // Change to sign up mode
            signUpOrLogin.setTitle("Sign Up", for: [])
            changeSignUpModeButton.setTitle("Log In", for: [])
            messageLabel.text = "Already have an account?"
            signUpMode = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current()!.username != nil {
            
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
