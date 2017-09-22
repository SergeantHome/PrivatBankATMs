//
//  DetailViewController.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/21/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var atmInfo: ATMInfo!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet var workTimeLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Форматируем и отображаем адрес банкомата
        addressLabel.text = atmInfo.fullAddress.first!?.replacingOccurrences(of: ",", with: ", ")
        placeLabel.text = atmInfo.place.first!
        // Отображаем информацию о времени работы
        for (index, workTime) in atmInfo.workTime.enumerated() {
            workTimeLabels[index].text = workTime
        }
    }

}
