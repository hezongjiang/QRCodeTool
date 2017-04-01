//
//  ViewController.swift
//  QRCode
//
//  Created by he on 2017/4/1.
//  Copyright © 2017年 he. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QRCodeTool.shared.begainScan(inView: view) { (results) in
            print(results)
        }
    }


}

