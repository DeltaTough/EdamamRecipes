//
//  UIViewController+Alert.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 03/10/2024.
//

import UIKit

extension UIViewController{
    
    public func showAlertMessage(title: String, message: String){
        let alertMessagePopUpBox = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okButton = UIAlertAction(title: "OK", style: .default)
        alertMessagePopUpBox.addAction(okButton)
        self.present(alertMessagePopUpBox, animated: true)
    }
}
