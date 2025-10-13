//
//  NetworkMonitor.swift
//  TravelSchedule
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor.queue")
    
    @Published private(set) var isOnline: Bool = true
    private let subject = CurrentValueSubject<Bool, Never>(true)
    private var bag = Set<AnyCancellable>()
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.subject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
        
        subject
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.isOnline = $0 }
            .store(in: &bag)
    }
}
