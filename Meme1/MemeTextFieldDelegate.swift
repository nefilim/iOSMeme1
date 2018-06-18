//
//  MemeTextFieldDelegate.swift
//  Meme1
//
//  Created by peter on 6/17/18.
//  Copyright © 2018 peter. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {

    let TopTextFieldTag = 1
    let BottomTextFieldTag = 2
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            // we're using the tags to make sure we're checking the top field for "TOP" and the bottom field for "BOTTOM
            // otherwise the same would occur if "TOP" is entered in the bottom text field for example. is there a better way to do this?
            if (TopTextFieldTag == textField.tag && "TOP" == text) || (BottomTextFieldTag == textField.tag && "BOTTOM" == text) {
                print("clearing default text")
                textField.text = ""
            } else {
                print("NOT clearing non default text")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
