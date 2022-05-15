//
//  ViewController.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 07.01.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var tm = TimeMatrices()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var routeButton: UIButton!
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    // Массив для данных из GEOJSON
    var places: [Places] = []
    
    // Переменные для данных из MenuViewController
    var timeLimit: Double!
    var startAddress: String!
    var city: String!
    var startCoordinates = CLLocationCoordinate2D()
    var addTime: Bool!
    
    // Для построения маршрута
    var tour: [Places] = []
    var sumTime = 0.0
    var timeRoute = Double()
    var timeM: [Double] = []
    //var route: MKRoute!
    var time: Double?
    var time1 = Double()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // регистрация класса с идентификатором повторного использования
        mapView.register(PlacesMarkersView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // вызов функции считывания данных из файла geojson в массив places
        loadInitialData()
        
        // вызов функции преобразования стартовой точки
        startAddress(addressPlace: startAddress)
        
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        
        //mapView.addAnnotations(places)
        
        // Добавление начальной точки при загрузке карты (теперь в startAddress)
        //let initialLocation = CLLocation(latitude: 54.7769070, longitude: 32.0503850)
        //mapView.centerLocation(initialLocation)
        
        // Настройка максимального отдаления карты
        /*let cameraCenter = CLLocation(latitude: 59.929691, longitude: 30.362239)
        let region = MKCoordinateRegion(center: cameraCenter.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true) */
        
        // Создание и добавление на карту аннотации вручную
        /* let bB = Places(
            title: "Big Ben",
            locationName: "Лондон, Сити-оф-Ветминстер",
            discipline: "Clock",
            coordinate: CLLocationCoordinate2D(latitude: 51.5007286, longitude: 0.124583))
        mapView.addAnnotation(bB)*/
        
        mapView.showsUserLocation = true
    }
    
    // Метод для преобразования стартового адреса, добавления его в начало массива с достопримечательностями и как начальной точки при загрузке карты
    func startAddress(addressPlace: String) {
        var sP: Places!
        if (addressPlace == "Моё местоположение") {
            sP = Places(
                title: "Точка старта",
                locationName: "\(addressPlace)",
                discipline: "Я",
                coordinate: startCoordinates)
            self.places.insert(sP, at: 0)
            self.mapView.addAnnotations(self.places)
            
            // Добавление начальной точки при загрузке карты
            let initialLocation = CLLocation(latitude: startCoordinates.latitude, longitude: startCoordinates.longitude)
            self.mapView.centerLocation(initialLocation)
            
            /*for i in 0...self.places.count-1 {
                print(self.places[i].title)
            }*/
            
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressPlace) { placemarks, error in
                guard let placemarks = placemarks else { return}
                let placemark = placemarks.first
                guard let placemarkLocation = placemark?.location else { return }
                sP = Places(
                    title: "Точка старта",
                    locationName: "\(addressPlace)",
                    discipline: "Я",
                    coordinate: placemarkLocation.coordinate)
                self.places.insert(sP, at: 0)
                self.mapView.addAnnotations(self.places)
                
                // Добавление начальной точки при загрузке карты
                let initialLocation = CLLocation(latitude: placemarkLocation.coordinate.latitude, longitude: placemarkLocation.coordinate.longitude)
                self.mapView.centerLocation(initialLocation)
               
                /*for i in 0...self.places.count-1 {
                    print(self.places[i].title)
                }*/
            }
        }
    }
    
    // функция для считывания данных из файла geojson в массив places
   func loadInitialData() {
        var fileName = String()
        switch city {
        case "Смоленск":
            fileName = "PlacesSmolensk"
        case "Москва":
            fileName = "PlacesMoscow"
        case "Санкт-Петербург":
            fileName = "PlacesStPeterburg"
        case "Казань":
            fileName = "PlacesKazan"
        case "Калининград":
            fileName = "PlacesKaliningrad"
        case "Тест":
            fileName = "Test"
        default:
            fileName = "PlacesSmolensk"
        }
        
        guard
            let fileName = Bundle.main.url(forResource: fileName, withExtension: "geojson"),
            let placesData = try? Data(contentsOf: fileName)
        else { return }
        do {
            let features = try MKGeoJSONDecoder()
                .decode(placesData)
                .compactMap {$0 as? MKGeoJSONFeature}
            
            let validWorks = features.compactMap(Places.init)
            places.append(contentsOf: validWorks)
        } catch {
            print ("\(error)")
        }
    }
    
    // Функция для построения маршрута между двумя точками и расчета времени в пути
    
    // Попытка с построеним маршрута
    func createDirectionRequestRoute(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        //var time: Double?
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let response = response {
                let route = response.routes[0]
                //var route = response.routes[0]
                //time = route.expectedTravelTime/180
                //print("тайм внутри \(time)")
                //self.timeM.append(time!)
                //print("тайм массив внутри \(self.timeM)")
                self.mapView.addOverlay(route.polyline)
            }
        }
        //print("тайм массив снаружи \(self.timeM)")
    }
    

    
    // Попытка 3 (последняя работающая)
    /* func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (_ timeRoute: Double?) ->()) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        var time: Double?
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let route = response?.routes[0] {
                time = route.expectedTravelTime/180
                self.mapView.addOverlay(route.polyline)
            }
            completion(time)
        }
    }*/
    
    // Для заполнения матриц времени
    func createDirectionRequestTime(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (_ timeRoute: Double?) ->()) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        var time: Double?
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let route = response?.routes[0] {
                let poly = route.polyline
                print("poly in calc \(poly)")
                let coords = poly.coordinate
                print("coords in calc \(coords)")
                time = route.expectedTravelTime/180
                //self.mapView.addOverlay(route.polyline)
            }
            completion(time)
        }
    }
    
    // Попытка 4 (без completion, скрин в папке)
   /* func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
       let startLocation = MKPlacemark(coordinate: startCoordinate)
       let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
       
       let request = MKDirections.Request()
       request.source = MKMapItem(placemark: startLocation)
       request.destination = MKMapItem(placemark: destinationLocation)
       request.transportType = .walking
       request.requestsAlternateRoutes = true
       
       var time: Double?
        //var time2 = Double()
       
       let direction = MKDirections(request: request)
       direction.calculate {response, error in
           if let route = response?.routes[0] {
               time = route.expectedTravelTime/180
               print("внутри if \(time)")
               //time1 = route.expectedTravelTime/180
               //time2 = route.expectedTravelTime/180
               //self.mapView.addOverlay(route.polyline)
               self.mapView.addOverlay(route.polyline)
           }
           print("внутри calc \(time)")
       }
        print("внутри crDirR \(time)")
        //return time2
   }*/
    
    // Попытка 5 (без completion c async, действующая)
    func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) async throws -> Double {
       let startLocation = MKPlacemark(coordinate: startCoordinate)
       let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
       
       let request = MKDirections.Request()
       request.source = MKMapItem(placemark: startLocation)
       request.destination = MKMapItem(placemark: destinationLocation)
       request.transportType = .walking
       request.requestsAlternateRoutes = true
       
       let direction = MKDirections(request: request)
        let time2 = try await direction.calculate().routes[0].expectedTravelTime/180
    
        //print("внутри crDirR \(time2)")
        return time2
   }
    
    
    // Функция по построению итогового маршрута
    
    // Попытка с async, действующая
   /* @objc func routeButtonTapped() {
        
        async {
            print("StartA")
            let places1 = places
            
            for i in 0...places1.count-1 {
                print(places1[i].title!)
            }
            //print(places1[0].title,places1[1].title,places1[2].title,places1[3].title,places1[4].title,places1[5].title,places1[6].title,places1[7].title,places1[8].title,places1[9].title)
            var vertex = places1[0]
            print("vertex \(vertex.title)")
            var vj = 0
            var v = 0
            var aT = 0.0
            if addTime == true { aT = 10.0 }
             tour.append(vertex)
             while tour.count < places1.count {
                 var tmp = 1000000.0
                 for j in 1...places1.count-1 {
                     let t = try await createDirectionRequest(startCoordinate: places1[v].coordinate, destinationCoordinate: places1[j].coordinate)
                     print("до \(j) t =  \(t)")
                     let s = tour.contains(places1[j])
                     print(s)
                         if t < tmp, tour.contains(places1[j]) == false {
                             tmp = t
                             vj = j
                         } //if
                 } //for
                 if sumTime + tmp + aT <= timeLimit {
                     print("Вошли")
                     print("sumTime1 \(sumTime)")
                     print("tmp \(tmp)")
                     sumTime = sumTime + tmp + aT
                     print("sumTime2 \(sumTime)")
                     v = vj
                     vertex = places1[vj]
                     tour.append(vertex)
                 }
                 else {
                     print("Не Вошли")
                     break
                     
                 }
             } //while
            for k in 0...tour.count-1 {
                print(tour[k].title!)
            }
            for r in 0...tour.count-2 {
                createDirectionRequestRoute(startCoordinate: tour[r].coordinate, destinationCoordinate: tour[r+1].coordinate)
            }
            //print(tour[0].title,tour[1].title,tour[2].title,tour[3].title,tour[4].title,tour[5].title,tour[6].title,tour[7].title,tour[8].title,tour[9].title)
    
            // Проверка, что считает только 50 значений
            /*let places1 = places
            for j in 1...places1.count-1 {
                let t = try await createDirectionRequest(startCoordinate: places1[0].coordinate, destinationCoordinate: places1[j].coordinate)
                print("до \(j) t =  \(t)")
                timeM.append(t)
                print(timeM)
            }*/
            
            /*let a = CLLocationCoordinate2D(latitude: 54.78858495164944, longitude:  32.05470512883579)
            let b = CLLocationCoordinate2D(latitude: 54.779619164622865, longitude:  32.04564361534319)
            let t = try await createDirectionRequest(startCoordinate: a, destinationCoordinate: b)*/
            
            //Построение маршрута по порядку places
            /*for r in 0...places.count-2 {
                createDirectionRequestRoute(startCoordinate: places[r].coordinate, destinationCoordinate: places[r+1].coordinate)
            }*/
               
            print("FinishA")
        }
    }*/
    
    
    //Для заполнения матриц времени
    @objc func routeButtonTapped() {
        for i in 1...places.count-1 {
            createDirectionRequestTime(startCoordinate: places[2].coordinate, destinationCoordinate: places[i].coordinate) { [self] time in
                guard let time = time else { return }
                tm.PlacesSmolensk[1][i-1]=time
                print("время номер \(i) равен \(time)")
                print("время массив \(tm.PlacesSmolensk)")
                //completion(self.timeM)
            }
        }
        //completion(self.timeM)
        //print("массив времени после \(self.timeM)")
    }
    
    // Для отрисовки маршрута
   /* @objc func routeButtonTapped() {
        //var route = MKRoute()
        var route1 = [MKRoute](0x600003976ea0)
        //mapView.addOverlay(route1.polyline)
        //self.mapView.addOverlay(route.polyline)
    }*/
    
    
    
}


//создание расширений
extension MKMapView {
    //метод для настройки масштаба карты
    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    // метод для отображения линии маршрута
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .init(red: 2/255.0, green: 62/255.0, blue: 138/255.0, alpha: 1.0)
        renderer.lineWidth = 3
        return renderer
    }
}




/*@objc func routeButtonTapped() {
    print("Hello")
    createDirectionRequest(startCoordinate: places[0].coordinate, destinationCoordinate: places[1].coordinate) { double, error in
        guard let timeRoute = double, error == nil else { return }
        print(timeRoute)
    }
    //print(a.timeRoute)
    /*if a.route != nil {
        print(a.timeRoute)
        mapView.addOverlay(a.route?.polyline as! MKOverlay)
        mapView.showAnnotations(places, animated: true)
    }*/
    
    //mapView.addOverlay(routeVal?.polyline as! MKOverlay)
    /*var vertex = places[0]
    var vj = 0
    var v = 0
    tour.append(vertex)
    while tour.count < places.count {
        var tmp = 1000000.0
        for j in 1...places.count-1 {
            let crDirR = createDirectionRequest(startCoordinate: places[v].coordinate, destinationCoordinate: places[j].coordinate)
            let s = tour.contains(places[j])
                if crDirR.timeRoute < tmp, s == false {
                    tmp = crDirR.timeRoute
                    vj = j
                }
                v = vj
                vertex = places[vj]
                tour.append(vertex)
        }
    }
    /*for r in 0...tour.count-2 {
        var crDirRFin = createDirectionRequest(startCoordinate: tour[r].coordinate, destinationCoordinate: tour[r+1].coordinate)
        if crDirRFin.route != nil {
            var routeVal = crDirRFin.route
            self.mapView.addOverlay(routeVal?.polyline as! MKOverlay)
        }
    }*/
    //mapView.showAnnotations(tour, animated: true)
        
        //print(tour[0].title,tour[1].title,tour[2].title,tour[3].title,tour[4].title,tour[5].title,tour[6].title,tour[7].title,tour[8].title,tour[9].title)
        //mapView.addOverlay(self.route.polyline) */
    }*/

//Функция для постоения матрицы времени
/*func createMatrixTime(completion: @escaping (_ matrixRoute: [[Double]]?) ->()) {
    var matrixRoute = Array(repeating: Array(repeating: 0.0, count: places.count), count: places.count)
    for (i,row) in matrixRoute.enumerated() {
        for (j,element) in row.enumerated() {
            createDirectionRequest(startCoordinate: places[i].coordinate, destinationCoordinate: places[j].coordinate) { timeRoute in
                guard let timeRoute = timeRoute else { return }
                matrixRoute[i][j] = timeRoute
                completion(matrixRoute)
            }
        }
    }
    //completion(matrixRoute)
}*/

//Функция для построения массива
/*func createArrayTime(completion: @escaping (_ timeM: [Double]?) ->()) {
    print("начало пустой \(self.timeM)")
    timeM = Array(repeating: 0.0, count: places.count-1)
    for i in 1...places.count-1 {
        createDirectionRequest(startCoordinate: places[0].coordinate, destinationCoordinate: places[i].coordinate) { time in
            guard let time = time else { return }
            self.timeM[i-1]=time
            //print("время номер \(i) равен \(time)")
            //print("время массив \(self.timeM)")
            completion(self.timeM)
        }
    }
    //completion(self.timeM)
    print("массив времени после \(self.timeM)")
}*/

//Алгоритм
/*let places1 = places
print(places1[0].title,places1[1].title,places1[2].title,places1[3].title,places1[4].title,places1[5].title,places1[6].title,places1[7].title,places1[8].title,places1[9].title)
var vertex = places1[0]
print("vertex \(vertex.title)")
 var vj = 0
 var v = 0
 tour.append(vertex)
 while tour.count < places1.count {
     var tmp = 1000000.0
     for j in 1...places1.count-1 {
         let t = try await createDirectionRequest(startCoordinate: places1[v].coordinate, destinationCoordinate: places1[j].coordinate)
         print("до \(j) t =  \(t)")
         let s = tour.contains(places1[j])
         print(s)
             if t < tmp, s == false {
                 tmp = t
                 vj = j
             } //if
     } //for
     v = vj
     vertex = places1[vj]
     tour.append(vertex)
 } //while
 print(tour[0].title,tour[1].title,tour[2].title,tour[3].title,tour[4].title,tour[5].title,tour[6].title,tour[7].title,tour[8].title,tour[9].title) */
