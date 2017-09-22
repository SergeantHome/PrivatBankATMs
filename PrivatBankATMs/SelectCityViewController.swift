//
//  SelectCityViewController.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/21/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import UIKit

class SelectCityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // Список городов, для которых отображаются банкоматы
    let cityNames = ["Киев", "Харьков", "Полтава", "Сумы", "Винница", "Черкассы", "Кременчуг", "Днепропетровск", "Бровары", "Белая Церковь"]
    let kCityNameCellIdentifier = "CityNameCell"
    let kRowHeight: CGFloat = 44.0
    var selectedCityName: String!
    // Callback функция о выборе города
    var onSelect: ((_ selectedCityName: String) -> Void) = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настраиваем длину таблицы, пропорционально количеству городов в списке
        tableViewHeightConstraint.constant = kRowHeight * CGFloat(cityNames.count) - 1.0
    }

}

extension SelectCityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCityNameCellIdentifier, for: indexPath)
        let cityName = cityNames[indexPath.row]
        cell.textLabel?.text = cityName
        // Отображаем галочку для текущего выбранного города
        if let selectedCityName = selectedCityName, selectedCityName == cityName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension SelectCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // После выбора города вызываем Callback функцию и прячем экран
        onSelect(cityNames[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
