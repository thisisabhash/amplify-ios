//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine

@available(iOS 13.0, *)
extension RemoteSyncEngine {
    struct Resolver {
        // swiftlint:disable cyclomatic_complexity
        static func resolve(currentState: State, action: Action) -> State {
            switch (currentState, action) {
            case (.notStarted, .receivedStart):
                return .pausingSubscriptions

            case (.pausingSubscriptions, .pausedSubscriptions):
                return .pausingMutationQueue

            case (.pausingMutationQueue, .pausedMutationQueue(let api, let storageEngineAdapter)):
                return .initializingSubscriptions(api, storageEngineAdapter)

            case (.initializingSubscriptions, .initializedSubscriptions):
                return .performingInitialSync
            case (.initializingSubscriptions, .errored(let error)):
                return .cleaningUp(error)
            case (.initializingSubscriptions, .finished):
                return .cleaningUp(nil)


            case (.performingInitialSync, .performedInitialSync):
                return .activatingCloudSubscriptions
            case (.performingInitialSync, .errored(let error)):
                return .cleaningUp(error)
            case (.performingInitialSync, .finished):
                return .cleaningUp(nil)


            case (.activatingCloudSubscriptions, .activatedCloudSubscriptions(let api, let mutationEventPublisher)):
                return .activatingMutationQueue(api, mutationEventPublisher)
            case (.activatingCloudSubscriptions, .errored(let error)):
                return .cleaningUp(error)
            case (.activatingCloudSubscriptions, .finished):
                return .cleaningUp(nil)

            case (.activatingMutationQueue, .activatedMutationQueue):
                return .notifyingSyncStarted
            case (.activatingMutationQueue, .errored(let error)):
                return .cleaningUp(error)
            case (.activatingMutationQueue, .finished):
                return .cleaningUp(nil)

            case (.notifyingSyncStarted, .notifiedSyncStarted):
                return .syncEngineActive

            case (.syncEngineActive, .errored(let error)):
                return .cleaningUp(error)
            case (.syncEngineActive, .finished):
                return .cleaningUp(nil)

            case (.cleaningUp, .cleanedUp(let error)):
                return .schedulingRestart(error)

            case (.schedulingRestart, .scheduleRestartFinished):
                return .pausingSubscriptions

            default:
                log.warn("Unexpected state transition. In \(currentState.displayName), got \(action.displayName)")
                log.verbose("Unexpected state transition. In \(currentState), got \(action)")
                return currentState
            }
        }
    }
}