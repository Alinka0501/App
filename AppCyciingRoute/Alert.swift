//
//  Alert.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 28.02.2022.
//

import UIKit

extension UIViewController {
    func showAlertLocation(title: String, message: String, url: URL?){
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         let settingsAction = UIAlertAction(title: "Настройки", style: .default) { alert in
             if let url = url{
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
             }
         }
         let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
         alert.addAction(settingsAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
     }
    
    func showAlertError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
