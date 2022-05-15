//
//  MenuViewController.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 26.01.2022.
//

import UIKit
import MapKit

class MenuViewController: UIViewController {
    
    //var vc = ViewController()
    
    // Для работы с местоположением
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tFStartAddress: UITextField!
    @IBOutlet weak var pickerViewCity: UIPickerView!
    @IBOutlet weak var tFTimeLimit: UITextField!
    @IBOutlet weak var switchAddTime: UISwitch!
    
    //var cities: [String] = [String]()
    var cities = ["Москва","Санкт-Петербург","Казань","Смоленск","Калининград","Тест"]
    var city = "Смоленск"
    var startCoordinates = CLLocationCoordinate2D()
    
    

    @IBAction func goToMap(_ sender: UIButton) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let startAddress = tFStartAddress.text
        newVC.startAddress = startAddress
        let timeLimit: Double? = Double(tFTimeLimit.text!)
        newVC.timeLimit = timeLimit
        newVC.city = city
        newVC.startCoordinates = startCoordinates
        newVC.addTime = switchAddTime.isOn
        if tFStartAddress.text != "", tFTimeLimit.text != "" {
            navigationController?.pushViewController(newVC, animated: true)
        }
        else if tFTimeLimit.text == "" {
            tFTimeLimit.attributedPlaceholder = NSAttributedString(string: "Заполните поле", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        }
        else if tFStartAddress.text == "" {
            tFStartAddress.attributedPlaceholder = NSAttributedString(string: "Заполните поле", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        }
    }
    
    @IBAction func tap(_ sender: Any) {
        tFTimeLimit.resignFirstResponder()
        tFStartAddress.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerViewCity.dataSource = self
        pickerViewCity.delegate = self
        tFStartAddress.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        //cities = ["Смоленск", "Москва","Санкт-Петербург","Париж","Казань","Калининград","Тест"]
        
        // Вызов функции, получающей разрешение у пользователя на использование его местоположения
        retrieveCurrentLocation()
        
        pickerViewCity.selectRow(3, inComponent: 0, animated: true)
        
    
    }
    
    
    // Функция, получающая разрешение у пользователя на использование его местоположения
   func retrieveCurrentLocation(){
       let status = CLLocationManager.authorizationStatus()
       if (!CLLocationManager.locationServicesEnabled()) {
           showAlertLocation(title: "У Вас выключена служба геолокации", message: "Хотите включить её?", url: URL(string: "App-Prefs:root=LOCATION_SERVICES"))
           return
       }
       if (status == .denied) {
           // по url открываем настройки приложения
           showAlertLocation(title: "Вы запретили использовать данные о Вашем местоположении.", message: "Хотите это изменить?", url: URL(string: UIApplication.openSettingsURLString))
           return
       }
       if (status == .notDetermined) {
           locationManager.requestWhenInUseAuthorization()
           return
       }
       //tFStartAddress.text = "Моё местоположение"
       locationManager.requestLocation()
    }
    
    
}

extension MenuViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
}

extension MenuViewController: UIPickerViewDelegate{
    /*func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row]
    }*/
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        city = cities[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Avenir Next", size: 23.0)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = cities[row]
        return pickerLabel!
    }
}

// Для местоположения пользователя
extension MenuViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate{
            tFStartAddress.text = "Моё местоположение"
            startCoordinates = location
        }
    }
    
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       retrieveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlertError(title: "Ошибка", message: "Не удалось определить Ваше местоположение")
    }
}

//Скрытие клавиатуры по кнопке Ввод
extension MenuViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tFStartAddress.resignFirstResponder()
        return true
    }
}
