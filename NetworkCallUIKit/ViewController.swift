//
//  ViewController.swift
//  NetworkCallUIKit
//
//  Created by Priyanka on 14/09/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    lazy var dataViewModel: ViewModel = {
        ViewModel { status, message in
            if status == false {
                print(message)
            }
        }
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataViewModel.apiGetData { data, status, message in
            if status == true {
                print(data?.dates as Any)
            } else {
                print("Error: \(message)")
            }
        }

    }

}

