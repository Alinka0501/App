//
//  MenuViewController.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 26.01.2022.
//

import UIKit
import MapKit

class MenuViewController: UIViewController {
    
    var vc = ViewController()
    
    // Для работы с местоположением
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tFStartAddress: UITextField!
    @IBOutlet weak var pickerViewCity: UIPickerView!
    
    var cities: [String] = [String]()
    var city = "Смоленск"
    var startCoordinates = CLLocationCoordinate2D()
    

    @IBAction func goToMap(_ sender: UIButton) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let startAddress = tFStartAddress.text
        newVC.startAddress = startAddress
        newVC.city = city
        newVC.startCoordinates = startCoordinates
        if tFStartAddress.text != ""{
            navigationController?.pushViewController(newVC, animated: true)
        } else {
            tFStartAddress.attributedPlaceholder = NSAttributedString(string: "Заполните поле", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerViewCity.dataSource = self
        pickerViewCity.delegate = self
        
        // Для скрытия клавиатуры
        tFStartAddress.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        cities = ["Смоленск", "Москва","Санкт-Петербург","Париж"]
        
        // Вызов функции, получающей разрешение у пользователя на использование его местоположения
        retrieveCurrentLocation()
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        city = cities[row]
    }
}

// Для местоположения пользователя
extension MenuViewController: CLLocationManagerDelegate{
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

extension MenuViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tFStartAddress.resignFirstResponder()
        return true
    }
}
