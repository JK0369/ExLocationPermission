//
//  LocationPermissionManager.swift
//  ExLocationPermission
//
//  Created by Jake.K on 2022/01/04.
//

import RxSwift
import RxCocoa
import RxCoreLocation
import CoreLocation

class LocationPermissionManager {
  static let shared = LocationPermissionManager()
  private let disposeBag = DisposeBag()
  
  let locationSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
  private let locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.distanceFilter = kCLDistanceFilterNone
    return manager
  }()
  
  private init() {
    // Bind Location
    self.locationManager.rx.didUpdateLocations
      .compactMap(\.locations.last?.coordinate)
      .bind(onNext: self.locationSubject.onNext(_:))
      .disposed(by: self.disposeBag)
    self.locationManager.startUpdatingLocation() // 이미 권한을 허용한 경우 케이스 대비
  }
  
  func requestLocation() -> Observable<CLAuthorizationStatus> {
    return Observable<CLAuthorizationStatus>
      .deferred { [weak self] in
        guard let ss = self else { return .empty() }
        ss.locationManager.requestWhenInUseAuthorization()
        return ss.locationManager.rx.didChangeAuthorization
          .map { $1 }
          .filter { $0 != .notDetermined }
          .do(onNext: { _ in ss.locationManager.startUpdatingLocation() })
          .take(1)
      }
  }
}

