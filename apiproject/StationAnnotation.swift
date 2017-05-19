//
//  StationAnnotation.swift
//  apiproject
//
//  Created by Johan Wejdenstolpe on 2017-05-08.
//  Copyright © 2017 Johan Wejdenstolpe. All rights reserved.
//

import UIKit
import MapKit

class StationAnnotation: NSObject, MKAnnotation {

    var title: String?
    var distance: String?
    var coordinate: CLLocationCoordinate2D
 
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
