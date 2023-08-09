//
//  ViewController.swift
//  DawnKit
//
//  Created by zhanghao on 08/09/2023.
//  Copyright (c) 2023 zhanghao. All rights reserved.
//

import UIKit
import DawnKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let btn = DawnButton()
        btn.backgroundColor = .random(.gentle)
        view.addSubview(btn)
        btn.dw.makeConstraints { make in
            make.top.equalTo(200)
            make.left.equalTo(50)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
