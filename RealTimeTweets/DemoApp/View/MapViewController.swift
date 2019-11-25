//
//  MapViewController.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Swifter
import SafariServices


// Point of Interest Item which implements the GMUClusterItem protocol.
class ClusterItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!
  var Id  : Int!

  init(position: CLLocationCoordinate2D, name: String, Id: Int) {
    self.position = position
    self.name = name
    self.Id   = Id
  }
}

let kCameraLatitude   = 30.7298742
let kCameraLongitude  = 76.7741056

class MapViewController: UIViewController {

    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    
    //private var viewModelMap = MapViewModel ()
    
    override func loadView() {
        DispatchQueue.main.async() {
            // Show loader
             ProgressHud.sharedIndicator.displayPrgressHud(on: self.view)
        }
         //observeEvents()
        
         // Register to receive location notification
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name: NSNotification.Name(rawValue: "updateMapWithStreamAPIData"), object: nil)
           
        // Set initilial camera position
        self.intialiseCamerPosition(lat: kCameraLatitude, long: kCameraLongitude)
        
        /*
        let initialiseRequestModel = APIRequestModel()
        initialiseRequestModel.apiPath = "statuses/filter.json"
        initialiseRequestModel.baseURL = .stream
        initialiseRequestModel.params = ["delimited":"1000","locations":"-122.75,36.8,-121.75,37.8"]
        initialiseRequestModel.requestCounter = 2
        viewModelMap.intialiseCall(requestParams: initialiseRequestModel)
        */
        
       }
       
    @objc func methodOfReceivedNotification(_ notification: NSNotification)  {
        if let dictInfo = notification.userInfo  as NSDictionary? {
            guard let liveTweetsData = dictInfo["APIResponse"] as? [ResponseModel] else {
                print("no tweets data")
                return
            }
               
            self.setupClusterManager(populateData: liveTweetsData)
            
            DispatchQueue.main.async() {
                // hide loader
                ProgressHud.sharedIndicator.hideProgressHud(onView: self.view)
            }
        }
    }
    
    //MARK: - Initialise camera position on the map
    func intialiseCamerPosition(lat: Double, long: Double) {
           
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                  longitude: long, zoom: 7)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
           
    }
    
    //MARK: - Initialise cluster manager for the map
    func setupClusterManager(populateData: [ResponseModel])  {
           
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

        // Generate and add random items to the cluster manager.
        generateClusterItems(tweetData: populateData)

        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()

        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
           
    }
       
    // MARK: - Private

    // Generates cluster items from lat, longs within some extent of the camera and adds them to the
    // cluster manager.
    private func generateClusterItems(tweetData: [ResponseModel]) {
        for index in 0...tweetData.count-1 {
            let lat  = tweetData[index].latitude
            let lng  = tweetData[index].longitude
            let name = tweetData[index].tweetText
            let Id   = tweetData[index].tweetId
            let item = ClusterItem(position: CLLocationCoordinate2DMake(lat, lng), name: name, Id: Id)
            clusterManager.add(item)
          }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          guard let destination = segue.destination as? TweetDetailViewController else { return }
          destination.tweetId = sender as! Int
      }
    /*
    // Function to observe various event call backs from the viewmodel as well as Notifications.
    private func observeEvents() {
        viewModelMap.reloadScreen = { tweetData, error in
                  
             if let errorMessage = error {
                print(errorMessage)
                return
             }
        }
    }
    */
}

// MARK: - GMUClusterManagerDelegate
extension MapViewController: GMUClusterManagerDelegate{
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
         let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
               zoom: mapView.camera.zoom + 2)
         let update = GMSCameraUpdate.setCamera(newCamera)
         mapView.moveCamera(update)
         return false
    }

}

// MARK: - GMUMapViewDelegate
extension MapViewController: GMSMapViewDelegate {

    // Marker tap handler method
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      if let poiItem = marker.userData as? ClusterItem {
        marker.snippet = poiItem.name
        marker.opacity = 1.0
      } else {
        NSLog("Did tap a normal marker")
      }
      return false
    }
    
    // Callout tap handler method
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let poiItem = marker.userData as? ClusterItem {
          let tweetID = poiItem.Id as Int
          self.performSegue(withIdentifier: "showTweetDetails", sender: tweetID)
        } else {
          NSLog("Did tap a normal marker")
        }
    }
    
     
}


