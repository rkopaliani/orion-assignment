//
//  Combine+AnyScheduler.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

private let logger = Logger(category: "AnyScheduler")

extension Scheduler {
    public func asAnyScheduler () -> AnyScheduler {.init(self) }
}

/// A type-erasing scheduler.
///
/// Do not use `SchedulerTimeType` across different `AnyScheduler` instance.
///
///     let scheduler1 = AnyScheduler(DispatchQueue.main.cx)
///     let scheduler2 = AnyScheduler(RunLoop.main.cx)
///
///     let time1 = scheduler1.now
///     let time2 = scheduler2.now
///
///     // DON'T DO THIS!
///     time1.distance(to: time2) // Will crash.
///
public final class AnyScheduler: Scheduler {

    public typealias SchedulerOptions = Never
    public typealias SchedulerTimeType = AnySchedulerTimeType

    public init<S: Scheduler>(_ scheduler: S, options: S.SchedulerOptions? = nil) {

        wrappedNow = {

            SchedulerTimeType(wrapping: scheduler.now)
        }

        wrappedMinimumTolerance = {

            SchedulerTimeType.Stride(wrapping: scheduler.minimumTolerance)
        }

        wrappedScheduleAction = { action in

            scheduler.schedule(options: options, action)
        }

        wrappedScheduleAfterToleranceAction = { date, tolerance, action in

            scheduler.schedule(

                after: date.wrapped as! S.SchedulerTimeType,
                tolerance: tolerance.asType(S.SchedulerTimeType.Stride.self),
                options: options, action
            )
        }

        wrappedScheduleAfterIntervalAction = { date, interval, tolerance, action in

            scheduler.schedule(

                after: date.wrapped as! S.SchedulerTimeType,
                interval: interval.asType(S.SchedulerTimeType.Stride.self),
                tolerance: tolerance.asType(S.SchedulerTimeType.Stride.self),
                options: options, action
            )
        }
    }

    // MARK: - Interface

    public var now: SchedulerTimeType { wrappedNow() }

    public var minimumTolerance: SchedulerTimeType.Stride { wrappedMinimumTolerance() }

    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {

        wrappedScheduleAction(action)
    }

    public func schedule(

        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void

    ) {

        wrappedScheduleAfterToleranceAction(date, tolerance, action)
    }

    public func schedule(

        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void

    ) -> Cancellable {

        wrappedScheduleAfterIntervalAction(date, interval, tolerance, action)
    }

    // MARK: - Privates

    private let wrappedNow: () -> SchedulerTimeType
    private let wrappedMinimumTolerance: () -> SchedulerTimeType.Stride
    private let wrappedScheduleAction: (@escaping () -> Void) -> Void
    private let wrappedScheduleAfterToleranceAction: (

        SchedulerTimeType,
        SchedulerTimeType.Stride,
        @escaping () -> Void

    ) -> Void

    private let wrappedScheduleAfterIntervalAction: (

        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerTimeType.Stride,
        @escaping () -> Void

    ) -> Cancellable
}

public struct AnySchedulerTimeType: Strideable {

    public struct Stride: Comparable, SignedNumeric, SchedulerTimeIntervalConvertible {

        public init(integerLiteral value: Int) {

            wrapped = .literal(.seconds(value))
        }

        public init?<T: BinaryInteger>(exactly source: T) {

            guard let literal = Int(exactly: source) else {

                return nil
            }

            self.init(integerLiteral: literal)
        }

        public var magnitude: Stride {

            // TODO: magnitude?
            fatalError("Not implemented.")
        }

        public static func == (lhs: Stride, rhs: Stride) -> Bool {

            switch (lhs.wrapped, rhs.wrapped) {

            case let (.opaque(left), .opaque(right)):

                return left.equalTo(right.wrapped)

            case let (.opaque(left), .literal(right)):

                return left.equalTo(left.makeOpaque(right).wrapped)

            case let (.literal(left), .opaque(right)):

                return right.makeOpaque(left).equalTo(right.wrapped)

            case let (.literal(left), .literal(right)):

                // TODO: potential precision loss
                return left.timeInterval == right.timeInterval
            }
        }

        public static func < (lhs: Stride, rhs: Stride) -> Bool {

            switch (lhs.wrapped, rhs.wrapped) {

            case let (.opaque(left), .opaque(right)):

                return left.lessThan(right.wrapped)

            case let (.opaque(left), .literal(right)):

                return left.lessThan(

                   left.makeOpaque(right).wrapped
                )

            case let (.literal(left), .opaque(right)):

                return right.makeOpaque(left).lessThan(right.wrapped)

            case let (.literal(left), .literal(right)):
                // TODO: potential precision loss
                return left.timeInterval < right.timeInterval
            }
        }

        public static func + (lhs: Stride, rhs: Stride) -> Stride {

            switch (lhs.wrapped, rhs.wrapped) {

            case let (.opaque(left), .opaque(right)):

                return .init(.opaque(

                   left.add(right.wrapped)
                ))

            case let (.opaque(left), .literal(right)):

                return .init(.opaque(

                   left.add(left.makeOpaque(right).wrapped)
                ))

            case let (.literal(left), .opaque(right)):

                return .init(.opaque(

                   right.makeOpaque(left).add(right.wrapped)
                ))

            case let (.literal(left), .literal(right)):
                // TODO: potential precision loss
                return .seconds(left.timeInterval + right.timeInterval)
            }
        }

        public static func - (lhs: Stride, rhs: Stride) -> Stride {

            switch (lhs.wrapped, rhs.wrapped) {

            case let (.opaque(left), .opaque(right)):

                return .init(.opaque(

                    left.subtract(right.wrapped)
                ))

            case let (.opaque(left), .literal(right)):

                return .init(.opaque(

                    left.subtract(left.makeOpaque(right).wrapped)
                ))

            case let (.literal(left), .opaque(right)):

                return .init(.opaque(

                    right.makeOpaque(left).subtract(right.wrapped)
                ))

            case let (.literal(left), .literal(right)):
                // TODO: potential precision loss
                return .seconds(left.timeInterval - right.timeInterval)
            }
        }

        public static func * (lhs: Stride, rhs: Stride) -> Stride {

            switch (lhs.wrapped, rhs.wrapped) {

            case let (.opaque(left), .opaque(right)):

                return .init(.opaque(

                    left.multiply(right.wrapped)
                ))

            case let (.opaque(left), .literal(right)):

                return .init(.opaque(

                    left.multiply(left.makeOpaque(right).wrapped)
                ))

            case let (.literal(left), .opaque(right)):

                return .init(.opaque(

                    right.makeOpaque(left).multiply(right.wrapped)
                ))

            case let (.literal(left), .literal(right)):
                // TODO: potential precision loss
                return .seconds(left.timeInterval * right.timeInterval)
            }
        }

        public static func += (lhs: inout Stride, rhs: Stride) {

            lhs = (lhs + rhs)
        }

        public static func -= (lhs: inout Stride, rhs: Stride) {

            lhs = (lhs - rhs)
        }

        public static func *= (lhs: inout Stride, rhs: Stride) {

            lhs = (lhs * rhs)
        }

        public static func seconds(_ seconds: Double) -> Stride {

            .init(.literal(.interval(seconds)))
        }

        public static func seconds(_ seconds: Int) -> Stride {

            .init(.literal(.seconds(seconds)))
        }

        public static func milliseconds(_ milliSeconds: Int) -> Stride {

            .init(.literal(.milliseconds(milliSeconds)))
        }

        public static func microseconds(_ microSeconds: Int) -> Stride {

            .init(.literal(.microseconds(microSeconds)))
        }

        public static func nanoseconds(_ nanoSeconds: Int) -> Stride {

            .init(.literal(.nanoseconds(nanoSeconds)))
        }

        // MARK: - Privates

        private struct Opaque {

            typealias Value = Comparable & SignedNumeric & SchedulerTimeIntervalConvertible

            let wrapped: any Value

            let add: (any Value) -> Opaque
            let equalTo: (any Value) -> Bool
            let lessThan: (any Value) -> Bool
            let multiply: (any Value) -> Opaque
            let subtract: (any Value) -> Opaque
            let makeOpaque: (SchedulerTimeLiteral) -> Opaque

            init<T: Value>(_ content: T) {

                wrapped = content
                equalTo = { anyValue in

                    guard let value = anyValue as? T else {

                        logger.critical("Can't cast: \(String(describing: anyValue)) to type:\(T.Type.self).")

                        return false
                    }

                    return content == value
                }

                lessThan = { anyValue in

                    guard let value = anyValue as? T else {

                        logger.critical("Can't cast: \(String(describing: anyValue)) to type:\(T.Type.self).")

                        return false
                    }

                    return content < value
                }

                add = { anyValue in

                    guard let value = anyValue as? T else {

                        logger.critical("Can't cast: \(String(describing: anyValue)) to type:\(T.Type.self).")

                        return .init(content)
                    }

                    return .init(content + value)
                }

                multiply = { anyValue in

                    guard let value = anyValue as? T else {

                        logger.critical("Can't cast: \(String(describing: anyValue)) to type:\(T.Type.self).")

                        return .init(content)
                    }

                    return .init(content * value)
                }

                subtract = { anyValue in

                    guard let value = anyValue as? T else {

                        logger.critical("Can't cast: \(String(describing: anyValue)) to type:\(T.Type.self).")

                        return .init(content)
                    }

                    return .init(content - value)
                }

                makeOpaque = { .init(T.time(literal: $0)) }
            }

        } // Opaque

        private enum Wrapped {

            case opaque(Opaque)
            case literal(SchedulerTimeLiteral)

        } // Wrapped

        private var wrapped: Wrapped

        private init(_ value: Wrapped) {

            wrapped = value
        }

        fileprivate init(wrapping opaque: any Comparable & SignedNumeric & SchedulerTimeIntervalConvertible) {

            wrapped = .opaque(.init(opaque))
        }

        fileprivate func asType<T: Comparable & SignedNumeric & SchedulerTimeIntervalConvertible>(

           _ type: T.Type

        ) -> T {

            switch wrapped {

            case let .opaque(opaque):

                return opaque.wrapped as! T

            case let .literal(literal):

                return T.time(literal: literal)
            }
        }

    } // Stride

    public func distance(to other: AnySchedulerTimeType) -> Stride {

        wrappedDistanceTo(other)
    }

    public func advanced(by value: Stride) -> AnySchedulerTimeType {

        wrappedAdvancedBy(value)
    }

    // MARK: - Privates

    fileprivate let wrapped: any Strideable

    private let wrappedDistanceTo: (AnySchedulerTimeType) -> Stride
    private let wrappedAdvancedBy: (Stride) -> AnySchedulerTimeType

    fileprivate init<T: Strideable>(wrapping opaque: T) where T.Stride: SchedulerTimeIntervalConvertible {

        self.wrapped = opaque

        self.wrappedDistanceTo = { other in

            .init(wrapping: opaque.distance(to: other as! T))
        }

        self.wrappedAdvancedBy = { time in

            .init(wrapping: opaque.advanced(by: time.asType(T.Stride.self)))
        }
    }

} // AnySchedulerTimeType

private enum SchedulerTimeLiteral {

    case seconds(Int)
    case milliseconds(Int)
    case microseconds(Int)
    case nanoseconds(Int)
    case interval(Double)

    var timeInterval: Double {

        switch self {

        case .seconds(let sec):

            return Double(sec)

        case .milliseconds(let milliSec):

            return Double(milliSec) * 1_000

        case .microseconds(let microSec):

            return Double(microSec) * 1_000_000

        case .nanoseconds(let nanoSec):

            return Double(nanoSec) * 1_000_000_000

        case .interval(let interval):

            return interval
        }
    }
}

extension SchedulerTimeIntervalConvertible {

    fileprivate static func time(literal: SchedulerTimeLiteral) -> Self {

        switch literal {

        case let .seconds(sec):

            return .seconds(sec)

        case let .interval(interval):

            return .seconds(interval)

        case let .nanoseconds(nanoSec):

            return .nanoseconds(nanoSec)

        case let .milliseconds(milliSec):

            return .milliseconds(milliSec)

        case let .microseconds(microSec):

            return .microseconds(microSec)
        }
    }
}
