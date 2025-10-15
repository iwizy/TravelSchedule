//
//  NetworkMonitor.swift
//  TravelSchedule
//

import Foundation
import Network
@preconcurrency import Combine

// MARK: - NetworkMonitor
@MainActor
final class NetworkMonitor: ObservableObject {
    // MARK: Singleton
    static let shared = NetworkMonitor()
    
    // MARK: Private properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor.queue")
    
    @Published private(set) var isOnline: Bool = true
    private let subject = CurrentValueSubject<Bool, Never>(true)
    private var bag = Set<AnyCancellable>()
    
    // MARK: Init
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.subject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
        
        subject
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.isOnline = $0 }
            .store(in: &bag)
    }
}
