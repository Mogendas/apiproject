//
//  ApiConnector.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-04.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import Foundation
import MapKit

protocol ApiConnectorDelegate: class {
    func showStationData(stations: [StationAnnotation])
    func showWeatherData(weatherData: [String: Any])
    func downloadError(error: String)
    func updateDownloadTime(time: String)
}

class ApiConnector {
    
    weak var delegate: ApiConnectorDelegate?
    
    var searchRadius: Int = 1000
    var maxResult: Int = 10
    var stations: [StationAnnotation] = [StationAnnotation]()
    var startDownloadTime: UInt = 0
    
    
    func getStations(location: CLLocation){
        
        var urlString = "http://api.sl.se/api2/nearbystops.json?key=11dc6f9c5b88426098e07cd020a4444c&originCoordLat="
        urlString += "\(location.coordinate.latitude)"
        urlString += "&originCoordLong="
        urlString += "\(location.coordinate.longitude)"
        urlString += "&maxresults="
        urlString += "\(maxResult)"
        urlString += "&radius="
        urlString += "\(searchRadius)"
        
        let url: URL = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            
            if data != nil {
                self.parseStationData(data!)
            }else{
                self.delegate?.downloadError(error: "Kunde inte ladda ner stationer")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                switch httpResponse.statusCode {

                case 400:
                    self.delegate?.downloadError(error: "Dålig förfrågan")
                    break
                case 404:
                    self.delegate?.downloadError(error: "Kunde inte hitta sidan")
                    break
                case 500:
                    self.delegate?.downloadError(error: "Internt fel på webbservern")
                    break
                default:
                    break
                }
            }
        }
        startDownloadTime = getCurrentMilliseconds()
        task.resume()
    }
    
    func parseStationData(_ data: Data) {
        var jsonResult: [String: Any] = [String: Any]()
        stations.removeAll()
        do {
            
            try jsonResult = JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as! [String: Any]
            
        } catch let error as NSError {
            print(error)
        }
        
        if let locationList = jsonResult["LocationList"] as? [String: Any], let stopLocations = locationList["StopLocation"] as? [[String: Any]] {

                for location in stopLocations {
                    if let name = location["name"] as? String, let latitude = location["lat"] as? String, let longitude = location["lon"] as? String, let distance = location["dist"] as? String {
                        var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
                        coordinates.latitude = Double(latitude)!
                        coordinates.longitude = Double(longitude)!
                        let station = StationAnnotation(coordinate: coordinates)
                        station.title = formatNameOfStation(name: name)
                        station.distance = distance
                        station.coordinate = coordinates
                        stations.append(station)
                    }
                }
            
            let currentMilliseconds = getCurrentMilliseconds()
            let timeToDownload: String = "\(currentMilliseconds - startDownloadTime) ms"
            
                DispatchQueue.main.async {
                    self.delegate?.updateDownloadTime(time: timeToDownload)
                    self.delegate?.showStationData(stations: self.stations)
                }
            
        }else{
            DispatchQueue.main.async {
                self.delegate?.showStationData(stations: self.stations)
            }
        }
    }
    
    func getWeather(name: String, coordinates: CLLocationCoordinate2D){
        var weatherUrl = "http://api.openweathermap.org/data/2.5/weather?lat="
        weatherUrl += "\(coordinates.latitude)"
        weatherUrl += "&lon="
        weatherUrl += "\(coordinates.longitude)"
        weatherUrl += "&appid=87a6bf1e2648b73aaac1a5fb1ac3791a"
        weatherUrl += "&units=metric&lang=se"
        
        let url: URL = URL(string: weatherUrl)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            if data != nil {
                self.parseWeatherData(data!, name: name)
            }else{
                self.delegate?.downloadError(error: "Kunde inte ladda ner vädret")
            }

            if let httpResponse = response as? HTTPURLResponse {
                
                switch httpResponse.statusCode {
                    
                case 400:
                    self.delegate?.downloadError(error: "Dålig förfrågan")
                    break
                case 404:
                    self.delegate?.downloadError(error: "Kunde inte hitta sidan")
                    break
                case 500:
                    self.delegate?.downloadError(error: "Internt fel på webbservern")
                    break
                default:
                    break
                }
            }
        }
        task.resume()
    }
    
    func parseWeatherData(_ data: Data, name: String){
        var jsonResult: [String: Any] = [String: Any]()
        var stationWeather: [String: Any] = [String: Any]()
        
        do {
            
            try jsonResult = JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as! [String: Any]
            
        } catch let error as NSError {
            print(error)
        }
        
        if let weather = jsonResult["weather"] as? [[String: Any]], let weatherInfo = weather.first, let weatherMain = jsonResult["main"] as? [String: Any], let weatherWind = jsonResult["wind"] as? [String: Any] {
            
            let tempDouble: Double = weatherMain["temp"] as! Double
            let temperature: String = String(format: "%.1f", tempDouble)
            let windSpeedDouble: Double = weatherWind["speed"] as! Double
            let windSpeed: String = String(format: "%.1f", windSpeedDouble)
            
            if let windDegrees = weatherWind["deg"] {
                stationWeather.updateValue("\(windDegrees)", forKey: "windDeg")
            }
            else{
                stationWeather.updateValue("0", forKey: "windDeg")
            }

            stationWeather.updateValue(name, forKey: "location")
            stationWeather.updateValue(weatherInfo["description"]! as! String, forKey: "description")
            stationWeather.updateValue(weatherInfo["icon"]! as! String, forKey: "icon")
            stationWeather.updateValue("\(temperature)", forKey: "temp")
            stationWeather.updateValue("\(windSpeed)", forKey: "windSpeed")
            DispatchQueue.main.async {
                self.delegate?.showWeatherData(weatherData: stationWeather)
            }
        }
    }
    
    func formatNameOfStation(name: String) -> String {
        var newName:String = ""
        let needle: Character = "("
        if var idx = name.characters.index(of: needle) {
            idx = name.characters.index(before: idx)
            newName = String(name.characters.prefix(upTo: idx))
        }
        else {
            newName = name
        }
        return newName
    }

    func getCurrentMilliseconds()->UInt{
        return  UInt(NSDate().timeIntervalSince1970 * 1000)
    }


}

