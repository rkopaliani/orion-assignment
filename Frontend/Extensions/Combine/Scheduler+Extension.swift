//
//  Scheduler+Extension.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine

extension Scheduler {

    /// Returns a publisher that repeatedly emits the scheduler's current time on the given
    /// interval.
    ///
    /// - Parameters:
    ///   - interval: The time interval on which to publish events. For example, a value of `0.5`
    ///     publishes an event approximately every half-second.
    ///   - tolerance: The allowed timingvariance when emitting events. Defaults to `nil`, which
    ///     allows anyvariance.
    ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
    /// - Returns: A publisher that repeatedly emits the current date on the given interval.
    func timerPublisher(

        every interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride? = nil,
        options: SchedulerOptions? = nil

    ) -> Publishers.Timer<Self> {

        .init(tolerance: tolerance, every: interval, options: options, scheduler: self)
    }

} // Scheduler
