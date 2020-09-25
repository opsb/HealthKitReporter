//
//  HealthKitObserver.swift
//  HealthKitReporter
//
//  Created by Florian on 23.09.20.
//

import Foundation
import HealthKit

public class HealthKitObserver {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func observerQuery(
        type: HealthKitType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping (String?, Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("Unknown type: \(type)")
        }
        let query = HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            guard error == nil else {
                updateHandler(nil, error)
                return
            }
            guard let id = query.objectType?.identifier else {
                updateHandler(
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)")
                )
                return
            }
            updateHandler(id, nil)
            completion()
        }
        healthStore.execute(query)
    }
    public func enableBackgroundDelivery(
        type: HealthKitType,
        frequency: HKUpdateFrequency,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) throws {
        guard let objectType = type.rawValue else {
            throw HealthKitError.invalidType("Unknown type: \(type)")
        }
        healthStore.enableBackgroundDelivery(
            for: objectType,
            frequency: frequency,
            withCompletion: completionHandler
        )
    }
    public func disableAllBackgroundDelivery(
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        healthStore.disableAllBackgroundDelivery(completion: completionHandler)
    }
    public func disableBackgroundDelivery(
        type: HealthKitType,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) throws {
        guard let objectType = type.rawValue else {
            throw HealthKitError.invalidType("Unknown type: \(type)")
        }
        healthStore.disableBackgroundDelivery(
            for: objectType,
            withCompletion: completionHandler
        )
    }
}