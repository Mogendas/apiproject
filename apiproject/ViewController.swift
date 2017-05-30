//
//  ViewController.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-04.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, ApiConnectorDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var mapSpan = 1000.0
    let connector = ApiConnector()
    var distanceToTravelBeforeUpdating: Double = 50
    var locationManager: CLLocationManager = CLLocationManager()
    var lastUpdate: Double = 0.0
    var lastLocationUpdate: CLLocation? = nil
    var weatherData: [String: Any]?
    var stations: [StationAnnotation]?
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var txtFieldLatitude: UITextField!
    @IBOutlet weak var txtFieldLongitude: UITextField!
    @IBOutlet weak var menuSC: UISegmentedControl!
    @IBOutlet weak var stationsTableView: UITableView!
    @IBOutlet weak var downloadMilliseconds: UILabel!

    @IBOutlet weak var settings: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        connector.delegate = self
        stationsTableView.delegate = self
        stationsTableView.dataSource = self
        stationsTableView.separatorStyle = .none
        menuSC.selectedSegmentIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userSettings = UserDefaults()
        
        if (userSettings.string(forKey: "SearchResult") != nil){
            connector.maxResult = Int(userSettings.string(forKey: "SearchResult")!)!
        }
        
        if (userSettings.string(forKey: "SearchRadius") != nil){
            connector.searchRadius = Int(userSettings.string(forKey: "SearchRadius")!)!
        }
        
        if (userSettings.string(forKey: "MoveRadius") != nil){
            distanceToTravelBeforeUpdating = Double(userSettings.string(forKey: "MoveRadius")!)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwinedAction(segue: UIStoryboardSegue){
        
    }
    @IBAction func btnSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Settings", sender: self)
    }
    
    @IBAction func menuChoice(_ sender: UISegmentedControl) {
        switch menuSC.selectedSegmentIndex {
        case 0:
            showMap()
            break
        case 1:
            showList()
            break
        default:
            
            break
        }
    }
    @IBAction func updateStations(_ sender: UIBarButtonItem) {
        if lastLocationUpdate != nil {
            connector.getStations(location: lastLocationUpdate!)
        }
        removeMapOverlays()
    }
    
    func showMap(){
        mapView.isHidden = false
        stationsTableView.isHidden = true
    }
    
    func showList(){
        stationsTableView.isHidden = false
        mapView.isHidden = true
    }
    
    func centerAtUserLocation(location: CLLocation){
        let center = CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: location.coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, mapSpan, mapSpan)
        mapView.setRegion(region, animated: true)
    }
    
    func getStations(location: CLLocation){
        connector.getStations(location: location)
        lastLocationUpdate = location
    }

    func showStationData(stations: [StationAnnotation]){
        self.stations = stations
        stationsTableView.reloadData()
        updatePins()
//        print(stations)
    }
    
    func updateDownloadTime(time: String){
        downloadMilliseconds.text = time
    }
    
    func showWeatherData(weatherData: [String: Any]){
        self.weatherData = weatherData
        performSegue(withIdentifier: "weather", sender: self)
    }
    
    func downloadError(error: String){
        let message = UIAlertController(title: "Fel", message: error, preferredStyle: .alert)
        message.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(message, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weather" {
            if let weatherVC = segue.destination as? WeatherVC {
                weatherVC.weatherData = weatherData
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stations != nil {
            return (stations?.count)!
        }else{
            return 0
        }  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = stationsTableView.dequeueReusableCell(withIdentifier: "stationCell") as! StationTableViewCell
        cell.stationName.text = stations![indexPath.row].title
        cell.stationDistance.text = stations![indexPath.row].distance
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let coordinates = stations?[indexPath.row].coordinate, let name = stations?[indexPath.row].title {
            connector.getWeather(name: name, coordinates: coordinates)
        }
    }
    
    func updatePins(){
        if mapView.annotations.count != 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        mapView.addAnnotations(stations!)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var distance:Double = 0.0

        if lastLocationUpdate == nil {
            lastLocationUpdate = userLocation.location
            getStations(location: userLocation.location!)
            centerAtUserLocation(location: userLocation.location!)
        } else {
            distance = (userLocation.location?.distance(from: lastLocationUpdate!))!
            //            print("Distance: \(distance)")
            if distance > distanceToTravelBeforeUpdating {
                lastLocationUpdate = userLocation.location
                getStations(location: userLocation.location!)
                centerAtUserLocation(location: userLocation.location!)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "Station"
        
        if annotation is StationAnnotation {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                let station = annotation as! StationAnnotation
                
                let btn = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = btn

//                let lblDistance = UILabel()
//                lblDistance.text = "\(station.distance!)m"
//                lblDistance.font = UIFont(name: lblDistance.font.fontName, size: (lblDistance.font.pointSize - 7))
//                lblDistance.sizeToFit()
                
                let btnDistance = UIButton(type: .system)
//                btnDistance.titleLabel?.text = "\(station.distance!)m"
                btnDistance.titleLabel?.font = UIFont(name: (btnDistance.titleLabel?.font.fontName)!, size: ((btnDistance.titleLabel?.font.pointSize)! - 4))
//                btnDistance.backgroundColor = UIColor.black
                btnDistance.setTitle("\(station.distance!)m", for: .normal)
                btnDistance.sizeToFit()
                
                annotationView.leftCalloutAccessoryView = btnDistance
                return annotationView
            }
        }
        
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let name = view.annotation?.title, let coordinates = view.annotation?.coordinate {
                connector.getWeather(name: name!, coordinates: coordinates)
            }
        }
        if control == view.leftCalloutAccessoryView {
            setDestination(coordinates: (view.annotation?.coordinate)!)
        }
    }
    
    func setDestination(coordinates: CLLocationCoordinate2D){
        removeMapOverlays()
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: (lastLocationUpdate?.coordinate)!))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        directionRequest.requestsAlternateRoutes = true
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.add(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    func removeMapOverlays(){
        for overlay:MKOverlay in mapView.overlays  {
            mapView.remove(overlay)
        }
    }
    
}

