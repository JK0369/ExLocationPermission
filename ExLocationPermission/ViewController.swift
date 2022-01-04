//
//  ViewController.swift
//  ExLocationPermission
//
//  Created by Jake.K on 2022/01/04.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  
  @IBOutlet weak var locationLabel: UILabel!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    LocationPermissionManager.shared.locationSubject
      .compactMap { $0 }
      .bind { [weak self] in self?.locationLabel.text = "\($0)" }
      .disposed(by: self.disposeBag)
  }
  
  @IBAction func didTapButton(_ sender: Any) {
    LocationPermissionManager.shared.requestLocation()
      .bind { print($0) }
      .disposed(by: self.disposeBag)
  }
}
