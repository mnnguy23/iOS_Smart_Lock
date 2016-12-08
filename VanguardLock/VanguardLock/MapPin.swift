//
//  MapPin.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/16/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import Foundation
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var islocked: Bool
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String, islocked: Bool) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.islocked = islocked
    }
}
