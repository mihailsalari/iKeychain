//
//  ViewController.swift
//  KeychainExample
//
//  Created by Developer on 1/26/17.
//  Copyright © 2017 Developer. All rights reserved.
//

import UIKit
import iKeychain

class ViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
            passwordTextField.clearsOnBeginEditing = true
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!

    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let key = try? iKeychain.default.getValue(forKey: Bundle.main.bundleIdentifier!) as? String {
            if key == nil {
                infoLabel.text = ""
            } else {
                infoLabel.text = "Your key was: \(key ?? "")"
            }
        } else {
            print("Key removed error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Action's

extension ViewController {
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if let key = infoLabel.text {
            do {
                try iKeychain.default.setValue(key, forKey: Bundle.main.bundleIdentifier!)
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        if iKeychain.default.remove(Bundle.main.bundleIdentifier!) {
           infoLabel.text = "Key was removed"
        } else {
            print("Key removed error")
        }
    }
}


// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        infoLabel.text = result
        
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        infoLabel.text?.removeAll()
        
        return true
    }
}
