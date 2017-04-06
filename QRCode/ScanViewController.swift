//
//  ScanViewController.swift
//  QRCode
//
//  Created by he on 2017/4/6.
//  Copyright © 2017年 he. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        QRCodeTool.shared.begainScan(inView: view) { (result) in
            
            for string in result {
                UIAlertView(title: nil, message: string, delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
    }

}
