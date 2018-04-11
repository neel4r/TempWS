//
//  ViewController.swift
//  CarTalk
//
//  Created by LakshmiNarayananN on 26/03/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire
import SwiftyJSON

struct Place {
    var name: String
    var location: CLLocationCoordinate2D
    var icon: String
}


class DetailViewController: UIViewController, MKMapViewDelegate
{
    var gmsMapView: GMSMapView!
    var mapView:UIView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let origin = "13.067439,80.237617"
        let destination = "11.004556,76.961632"

        let camera = GMSCameraPosition.camera(withLatitude: 13.067439,
                                              longitude: 80.237617,
                                              zoom: 0)
        gmsMapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), camera: camera)

        gmsMapView.setMinZoom(10, maxZoom: 15)
        self.view?.addSubview(gmsMapView)
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false"
        
        Alamofire.request(url).responseJSON { response in
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 3.0
                polyline.strokeColor = UIColor.red
                polyline.map = self.gmsMapView
            }
        }
        
        let myLocation = CLLocationCoordinate2D(latitude: 13.067439, longitude: 80.237617) //self.gmsMapView.myLocation?.coordinate
        findGasStation(at: myLocation, nearby: 1500) { [unowned self] places in
            self.add(places: places)
        }
    }
    
    func findGasStation(at location: CLLocationCoordinate2D, nearby: Int, handler: @escaping ([Place]) -> ()) {
        var places: [Place] = []
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=\(nearby)&type=gas_station&key=AIzaSyCcVY7BvOSp2U_p0f4SQbPDWd359zRsoOE" //

        Alamofire.request(url).responseJSON { response in
            let json = JSON(data: response.data!)
            let gasStations = json["results"].arrayValue
            for gasStation in gasStations {
                let name = gasStation["name"].stringValue
                let icon = gasStation["icon"].stringValue
                let locationCoordinates = gasStation["geometry"]["location"].dictionaryValue
                let latitude = locationCoordinates["lat"]?.double
                let longitude = locationCoordinates["lng"]?.double

                let location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                let gasStation = Place(name: name, location: location, icon: icon)
                places.append(gasStation)
            }
            handler(places)
        }
    }
    
    func add(places: [Place]) {
        DispatchQueue.main.async {
            let myLocation = CLLocationCoordinate2D(latitude: 13.067439, longitude: 80.237617) //self.gmsMapView.myLocation?.coordinate
            var bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: myLocation, coordinate: myLocation)

            for place in places {
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(place.location.latitude), longitude: CLLocationDegrees(place.location.longitude))
                let marker = GMSMarker(position: position)
                marker.title = place.name
                marker.map = self.gmsMapView
                
                bounds = bounds.includingCoordinate(position)
            }
            
            self.gmsMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

