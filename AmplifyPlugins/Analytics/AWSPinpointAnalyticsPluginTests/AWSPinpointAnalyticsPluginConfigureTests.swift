//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import AWSPinpointAnalyticsPlugin
import XCTest

class AWSPinpointAnalyticsPluginConfigureTests: AWSPinpointAnalyticsPluginTestBase {
    // MARK: Plugin Key test

    func testPluginKey() {
        let pluginKey = analyticsPlugin.key
        XCTAssertEqual(pluginKey, "awsPinpointAnalyticsPlugin")
    }

    // MARK: Configuration tests

    func testConfigureSuccess() {
        let appId = JSONValue(stringLiteral: testAppId)
        let region = JSONValue(stringLiteral: testRegion)
        let autoFlushInterval = JSONValue(integerLiteral: testAutoFlushInterval)
        let trackAppSession = JSONValue(booleanLiteral: testTrackAppSession)
        let autoSessionTrackingInterval = JSONValue(integerLiteral: testAutoSessionTrackingInterval)

        let pinpointAnalyticsPluginConfiguration = JSONValue(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.appIdConfigKey, appId),
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, region)
        )

        let regionConfiguration = JSONValue(dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.regionConfigKey, region))

        let analyticsPluginConfig = JSONValue(
            dictionaryLiteral:
            (AWSPinpointAnalyticsPluginConfiguration.pinpointAnalyticsConfigKey, pinpointAnalyticsPluginConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.pinpointTargetingConfigKey, regionConfiguration),
            (AWSPinpointAnalyticsPluginConfiguration.autoFlushEventsIntervalKey, autoFlushInterval),
            (AWSPinpointAnalyticsPluginConfiguration.trackAppSessionsKey, trackAppSession),
            (AWSPinpointAnalyticsPluginConfiguration.autoSessionTrackingIntervalKey, autoSessionTrackingInterval)
        )

        do {
            let analyticsPlugin = AWSPinpointAnalyticsPlugin()
            try analyticsPlugin.configure(using: analyticsPluginConfig)

            XCTAssertNotNil(analyticsPlugin.pinpoint)
            XCTAssertNotNil(analyticsPlugin.authService)
            XCTAssertNotNil(analyticsPlugin.autoFlushEventsTimer)
            XCTAssertNotNil(analyticsPlugin.appSessionTracker)
            XCTAssertNotNil(analyticsPlugin.globalProperties)
            XCTAssertNotNil(analyticsPlugin.isEnabled)
        } catch {
            XCTFail("Failed to configure analytics plugin")
        }
    }

}
