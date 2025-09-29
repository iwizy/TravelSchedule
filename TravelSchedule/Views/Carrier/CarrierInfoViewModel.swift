//
//  CarrierInfoViewModel.swift
//  TravelSchedule
//
//  Вью модель перевозчика

import SwiftUI
import Combine

final class CarrierInfoViewModel: ObservableObject {
    @Published private(set) var carrier: Carrier
    @Published var title: String = "Информация о перевозчике"
    
    init(carrier: Carrier) {
        self.carrier = carrier
    }
    
    func reloadFromNetwork() {
        // TODO: доработать
    }
}
