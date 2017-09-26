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
            // Записываем название города в title UINavigationController
            titleLabel.text = currentCityName
            let size = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            titleLabel.frame = CGRect(origin:CGPoint.zero, size:size)
        }
    }
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем mapView для отображения текущего местоположения и подписываемся на получение событий
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.camera = GMSCameraPosition.camera(withLatitude: 50.4501, longitude: 30.5234, zoom: 14.0)
        
        // Устанавливаем chevron only style backButton в UINavigationController
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Инициализируем titleView в UINavigationController для получения уведомлений о нажатиях на title
        titleLabel = titleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Если город не выбран, открываем диалог выбора города
        if currentCityName == nil {
            selectCity()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Отображение детальной информации о банкомате в DetailViewController
        if segue.identifier == kShowDetailSegueIdentifier {
            if let vc = segue.destination as? DetailViewController, let atmInfo = sender as? ATMInfo {
                vc.atmInfo = atmInfo
            }
        }
    }
    
    // MARK: - Actions
    
    // Выбор города при нажатии на иконку в navigationBar
    @IBAction func selectCityButtonTapped(_ sender: Any) {
        selectCity()
    }
    
    // Выбор города при нажатии на title в navigationBar
    @IBAction func titleViewTapped(_ sender: Any) {
        selectCity()
    }
    
    // MARK: - API methods
    
    // Запрос информации от сервера о банкоматах для указанного города
    func getATMInfo(cityName: String) {
        KRProgressHUD.show(withMessage: "Loading...")
        APIManager.shared.cityResource(cityName).load()
            .onSuccess { [weak self] data in
                self?.processResponse(data.content)
            }
            .onFailure { error in
                self.showErrorMessage(error.userMessage)
        }
    }
    
    // MARK: - Helpers
    
    // Инициализируем titleView в navigationBar UILabel, и привязываем к нему UITapGestureRecognizer для отслеживания нажатий на title
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
    
    // Загрузка SelectCityViewController для выбора города
    func selectCity() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectCityViewController") as! SelectCityViewController
        controller.selectedCityName = currentCityName
        controller.onSelect = { [unowned self] selectedCityName in
            self.afterSelectCity(selectedCityName)
        }
        present(controller, animated: true)
    }
    
    // Call-back функция, вызываемая после выбора города в дочернем контроллере
    func afterSelectCity(_ selectedCityName: String) {
        guard selectedCityName != currentCityName else { return }
        
        currentCityName = selectedCityName
        getATMInfo(cityName: selectedCityName)
    }
    
    func processResponse(_ response: Any) {
        if let atms = response as? CityATMsResponse {
            // Удаляем старые метки с карты
            mapView.clear()
            var bounds = GMSCoordinateBounds()
            for atmInfo in atms.devices {
                guard let latitude = atmInfo.latitude, let longitude = atmInfo.longitude else {
                    continue
                }
                let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                // Вычисляем границы области, где размещены банкоматы
                bounds = bounds.includingCoordinate(position)
                // Создаём маркер для банкомата на карте
                let marker = GMSMarker(position: position)
                marker.title = atmInfo.placeTitle
                marker.snippet = "Детальнее >>"
                marker.userData = atmInfo
                marker.map = mapView
            }
            var cameraUpdate: GMSCameraUpdate
            if let myLocation = mapView.myLocation?.coordinate {
                // Если известно моё местоположение, проряем, находимся мы в зоне размещения банкоматов
                if bounds.contains(myLocation) {
                    // Показываем ближайшие к моему местоположению банкоматы
                    cameraUpdate = GMSCameraUpdate.setTarget(myLocation, zoom: 14.0)
                } else {
                    // Показываем моё местоположение и банкоматы выбранного города
                    bounds = bounds.includingCoordinate(myLocation)
                    cameraUpdate = GMSCameraUpdate.fit(bounds)
                }
            } else {
                // Показываем банкоматы выбранного города
                cameraUpdate = GMSCameraUpdate.fit(bounds)
            }
            OperationQueue.main.addOperation { [weak self] in
                // Скрываем индикатор работы и позиционируем карту, для отображения выбранного региона
                KRProgressHUD.dismiss {
                    self?.mapView.animate(with: cameraUpdate)
                }
            }
        }
    }
    
    // Показываем сообщение об ошибке.
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Ошибка!", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            if let cityName = self?.currentCityName {
                self?.getATMInfo(cityName: cityName)
            }
        }
        alertController.addAction(retryAction)
        OperationQueue.main.addOperation { [weak self] in
            KRProgressHUD.dismiss {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        // Показываем экран с детальной информацией о банкомате
        performSegue(withIdentifier: kShowDetailSegueIdentifier, sender: marker.userData)
    }
}
