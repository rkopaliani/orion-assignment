//
//  Publishers+Timer.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import Foundation

extension Publishers {

    /// A publisher that emits a scheduler's current time on a repeating interval.
    ///
    /// This publisher is an alternative to Foundation's `Timer.publisher`, with its primary
    /// difference being that it allows you to use any scheduler for the timer, not just `RunLoop`.
    /// This is useful because the `RunLoop` scheduler is not testable in the sense that if you want
    /// to write tests against a publisher that makes use of `Timer.publisher` you must explicitly
    /// wait for time to pass in order to get emissions. This is likely to lead to fragile tests and
    /// greatly bloat the time your tests take to execute.
    ///
    /// It can be used much like Foundation's timer, except you specify a scheduler rather than a
    /// run loop:
    ///
    /// ```swift
    /// Publishers.Timer(every: .seconds(1), scheduler: DispatchQueue.main)
    ///   .autoconnect()
    ///   .sink { print("Timer", $0) }
    /// ```
    ///
    /// But more importantly, you can use it with `TestScheduler` so that any Combine code you write
    /// involving timers becomes more testable. This shows how we can easily simulate the idea of
    /// moving time forward 1,000 seconds in a timer:
    ///
    /// ```swift
    /// let scheduler = DispatchQueue.test
    /// var output: [Int] = []
    ///
    /// Publishers.Timer(every: 1, scheduler: scheduler)
    ///   .autoconnect()
    ///   .sink { _ in output.append(output.count) }
    ///   .store(in: &self.cancellables)
    ///
    /// XCTAssertEqual(output, [])
    ///
    /// scheduler.advance(by: 1)
    /// XCTAssertEqual(output, [0])
    ///
    /// scheduler.advance(by: 1)
    /// XCTAssertEqual(output, [0, 1])
    ///
    /// scheduler.advance(by: 1_000)
    /// XCTAssertEqual(output, Array(0...1_001))
    /// ```
    public final class Timer<S: Scheduler>: ConnectablePublisher {

        public typealias Output = S.SchedulerTimeType
        public typealias Failure = Never

        let tolerance: S.SchedulerTimeType.Stride?
        let interval: S.SchedulerTimeType.Stride
        let options: S.SchedulerOptions?
        let scheduler: S

        var isConnected: Bool {

            routingSubscription.isConnected
        }

        init(

            tolerance: S.SchedulerTimeType.Stride? = nil,
            every interval: S.SchedulerTimeType.Stride,
            options: S.SchedulerOptions? = nil,
            scheduler: S

        ) {

            self.scheduler = scheduler
            self.tolerance = tolerance
            self.interval = interval
            self.options = options
        }

        // MARK: Publisher

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {

            routingSubscription.addSubscriber(subscriber)
        }

        // MARK: ConnectablePublisher

        public func connect() -> Cancellable {

            routingSubscription.isConnected = true

            return routingSubscription
        }

        // MARK: - Privates

        private typealias Parent = Publishers.Timer

        /// Adapter subscription to allow `Timer` to multiplex to multiple subscribers
        /// the values produced by a single `TimerPublisher.Inner`
        private final class RoutingSubscription: Subscription, Subscriber, CustomStringConvertible, CustomReflectable {

            typealias Input = S.SchedulerTimeType
            typealias Failure = Never

            init(parent: Publishers.Timer<S>) {

                self.lock = Utilities.UnfairLock()
                self.inner = .init(parent, self)
            }

            var isConnected: Bool {

                get {

                    lock.lock()

                    defer {

                        lock.unlock()
                    }

                    return lockedIsConnected
                }

                set {

                    lock.lock()
                    let oldValue = lockedIsConnected
                    lockedIsConnected = newValue

                    // Inner will always be non-nil
                    let inner = self.inner!
                    lock.unlock()

                    guard newValue, !oldValue else {

                        return
                    }

                    inner.enqueue()
                }
            }

            // MARK: CustomStringConvertible

            var description: String { "Timer" }

            // MARK: CustomReflectable

            var customMirror: Mirror { inner.customMirror }

            var combineIdentifier: CombineIdentifier { inner.combineIdentifier }

            func addSubscriber<S: Subscriber>(_ sub: S) where S.Failure == Failure, S.Input == Output {

                lock.lock()
                subscribers.append(AnySubscriber(sub))
                lock.unlock()

                sub.receive(subscription: self)
            }

            // MARK: - Subscriber

            func receive(subscription: Subscription) {

                lock.lock()
                let subscribers = self.subscribers
                lock.unlock()

                for sub in subscribers {

                    sub.receive(subscription: subscription)
                }
            }

            func receive(_ value: Input) -> Subscribers.Demand {

                var resultingDemand: Subscribers.Demand = .max(0)
                lock.lock()
                let subscribers = self.subscribers
                let isConnected = lockedIsConnected
                lock.unlock()

                guard isConnected else {

                    return .none
                }

                for sub in subscribers {

                    resultingDemand += sub.receive(value)
                }

                return resultingDemand
            }

            func receive(completion: Subscribers.Completion<Failure>) {

                lock.lock()
                let subscribers = self.subscribers
                lock.unlock()

                for sub in subscribers {

                    sub.receive(completion: completion)
                }
            }

            // MARK: Subscription

            func request(_ demand: Subscribers.Demand) {

                lock.lock()

                // Inner will always be non-nil
                let inner = self.inner!
                lock.unlock()

                inner.request(demand)
            }

            func cancel() {

                lock.lock()
                lockedIsConnected = false
                self.subscribers = []
                lock.unlock()

                inner.cancel()
            }

            // MARK: - Privates

            private typealias ErasedSubscriber = AnySubscriber<Output, Failure>

            private let lock: Utilities.UnfairLock

            private var subscribers: [ErasedSubscriber] = []
            private var inner: Inner<RoutingSubscription>!
            private var lockedIsConnected = false

        } // RoutingSubscription

        private final class Inner<Downstream: Subscriber>: NSObject, Subscription, CustomReflectable
        where Downstream.Input == S.SchedulerTimeType, Downstream.Failure == Never {

            init(_ parent: Parent<S>, _ downstream: Downstream) {

                self.lock = Utilities.UnfairLock()
                self.parent = parent
                self.downstream = downstream
                self.started = false
                self.demand = .max(0)

                super.init()
            }

            // MARK: CustomReflectable

            var customMirror: Mirror {

                lock.lock()

                defer {

                    lock.unlock()
                }

                return .init(

                    self,
                    children: [

                        "downstream": downstream as Any,
                        "interval": parent?.interval as Any,
                        "tolerance": parent?.tolerance as Any,
                    ]
                )
            }

            // MARK: Override

            override var description: String { "Timer" }

            func enqueue() {

                lock.lock()

                guard let parent = parent, !started else {

                    lock.unlock()

                    return
                }

                started = true
                lock.unlock()

                cancellable = parent.scheduler.schedule(

                    after: parent.scheduler.now.advanced(by: parent.interval),
                    interval: parent.interval,
                    tolerance: parent.tolerance ?? .zero,
                    options: parent.options

                ) {

                    self.timerFired()
                }
            }

            // MARK: Subscription

            func request(_ number: Subscribers.Demand) {

                lock.lock()
                defer { lock.unlock() }
                guard parent != nil else {

                    return
                }

                demand += number
            }

            func cancel() {

                lock.lock()

                guard let time = cancellable else {

                    lock.unlock()

                    return
                }

                downstream = nil
                parent = nil
                started = false
                demand = .max(0)
                lock.unlock()

                time.cancel()
            }

            // MARK: - Privates

            private var demand: Subscribers.Demand
            private let lock: Utilities.UnfairLock
            private var cancellable: Cancellable?
            private var downstream: Downstream?
            private var parent: Parent<S>?
            private var started: Bool

            @objc
            private func timerFired() {

                lock.lock()

                guard let down = downstream, let parent = parent else {

                    lock.unlock()

                    return
                }

                // This publisher drops events on the floor when there is no space in the subscriber
                guard demand > 0 else {

                    lock.unlock()

                    return
                }

                demand -= 1
                lock.unlock()

                let extra = down.receive(parent.scheduler.now)
                guard extra > 0 else {

                    return
                }

                lock.lock()
                demand += extra
                lock.unlock()
            }

        } // Inner

        private lazy var routingSubscription: RoutingSubscription = {

            RoutingSubscription(parent: self)
        }()

    } // Tіmer

} // Publishers
