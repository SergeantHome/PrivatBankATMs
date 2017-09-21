//
//  MapViewController.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/19/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import UIKit
import GoogleMaps
import KRProgressHUD

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    let kShowDetailSegueIdentifier = "ShowDetail"
    
    var currentCityName: String! {
        didSet {
            titleLabel.text = currentCityName
            let size = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            titleLabel.frame = CGRect(origin:CGPoint.zero, size:size)
        }
    }
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.camera = GMSCameraPosition.camera(withLatitude: 50.4501, longitude: 30.5234, zoom: 15.0)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        titleLabel = titleView()
        selectCity()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kShowDetailSegueIdentifier {
            if let vc = segue.destination as? DetailViewController, let atmInfo = sender as? ATMInfo {
                vc.atmInfo = atmInfo
            }
        }
    }
    
    @IBAction func selectCityButtonTapped(_ sender: Any) {
        selectCity()
    }
    
    @IBAction func titleViewTapped(_ sender: Any) {
        selectCity()
    }
    
    func titleView() -> UILabel {
        let titleView = UILabel()
        titleView.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        titleView.textAlignment = .center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleViewTapped(_:)))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        return titleView
    }
    
    func selectCity() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectCityViewController") as! SelectCityViewController
        controller.selectedCityName = currentCityName
        controller.onSelect = { [unowned self] selectedCityName in
            self.afterSelectCity(selectedCityName)
        }
        present(controller, animated: true)
    }
    
    func afterSelectCity(_ selectedCityName: String) {
        currentCityName = selectedCityName
        KRProgressHUD.show(withMessage: "Loading...")
        APIManager.shared.cityResource(currentCityName).load().onSuccess { [weak self] data in
            self?.processResponse(data.content)
        }
    }
    
    func processResponse(_ response: Any) {
        if let atms = response as? CityATMsResponse {
            mapView.clear()
            var bounds = GMSCoordinateBounds()
            for atmInfo in atms.devices {
                let position = CLLocationCoordinate2D(latitude: atmInfo.latitude, longitude: atmInfo.longitude)
                bounds = bounds.includingCoordinate(position)
                let marker = GMSMarker(position: position)
                marker.title = atmInfo.place.first!
                marker.snippet = "Детальнее >>"
                marker.userData = atmInfo
                marker.map = mapView
            }
            if let myLocation = mapView.myLocation?.coordinate {
                bounds = bounds.includingCoordinate(myLocation)
            }
            let cameraUpdate = GMSCameraUpdate.fit(bounds)
            OperationQueue.main.addOperation { [weak self] in
                KRProgressHUD.dismiss()
                self?.mapView.animate(with: cameraUpdate)
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: kShowDetailSegueIdentifier, sender: marker.userData)
    }
}
