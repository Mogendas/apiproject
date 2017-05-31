//
//  WeatherVC.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-05.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import UIKit

class WeatherVC: UIViewController {
    
    var weatherData: [String: Any]?
    
    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var weatherTemperature: UILabel!
    @IBOutlet weak var weatherWindSpeed: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var windArrow: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let location = weatherData!["location"] as? String, let description = weatherData?["description"] as? String, let temp = weatherData?["temp"] as? String, let wind = weatherData?["windDeg"] as? String, let windSpeed = weatherData?["windSpeed"] as? String, let icon = weatherData?["icon"] as? String {

            switch icon {
            case "01d":
                weatherImage.image = #imageLiteral(resourceName: "01d")
                break
            case "01n":
                weatherImage.image = #imageLiteral(resourceName: "01n")
                break
            case "02d":
                weatherImage.image = #imageLiteral(resourceName: "02d")
                break
            case "02n":
                weatherImage.image = #imageLiteral(resourceName: "02n")
                break
            case "03d":
                weatherImage.image = #imageLiteral(resourceName: "03d")
                break
            case "03n":
                weatherImage.image = #imageLiteral(resourceName: "03n")
                break
            case "04d":
                weatherImage.image = #imageLiteral(resourceName: "04d")
                break
            case "04n":
                weatherImage.image = #imageLiteral(resourceName: "04n")
                break
            case "09d":
                weatherImage.image = #imageLiteral(resourceName: "09d")
                break
            case "09n":
                weatherImage.image = #imageLiteral(resourceName: "09n")
                break
            case "10d":
                weatherImage.image = #imageLiteral(resourceName: "10d")
                break
            case "10n":
                weatherImage.image = #imageLiteral(resourceName: "10n")
                break
            case "11d":
                weatherImage.image = #imageLiteral(resourceName: "11d")
                break
            case "11n":
                weatherImage.image = #imageLiteral(resourceName: "11n")
                break
            case "13d":
                weatherImage.image = #imageLiteral(resourceName: "13d")
                break
            case "13n":
                weatherImage.image = #imageLiteral(resourceName: "13n")
                break
            default:
                weatherImage.image = #imageLiteral(resourceName: "na")
            }
            
            weatherLocation.text = "\(location)"
            weatherDescription.text = "\(description.capitalized)"
            weatherTemperature.text = "\(temp)ºc"
            
            let degrees = Double(wind)

            let radians: CGFloat = CGFloat(degrees! * Double.pi/180)
            windArrow.transform = windArrow.transform.rotated(by: radians)
            weatherWindSpeed.text = "\(windSpeed) m/s"
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
