//
//  MyoDataCollector.swift
//  MyoSports
//
//  Created by Mark DiFranco on 2015-05-28.
//  Copyright (c) 2015 MDF Projects. All rights reserved.
//

import Foundation

class MyoDataCollector: NSObject {

    private var shouldRecord = false
    var isRecording: Bool {
        return shouldRecord
    }

    private var myo: TLMMyo? {
        return TLMHub.sharedHub().myoDevices().first as? TLMMyo
    }
    private let highPassFilterAlpha: Float = 0.8
    private var gravityVector = TLMVector3Make(0, 0, 0)

    private var recordingStartDate: NSDate?
    private var documentDirectory: String?

    private var accelFileName: String?
    private var gyroFileName: String?
    private var orientationFileName: String?
    private var emgFileName: String?

    private let accelQueue = dispatch_queue_create("AccelerationFileQueue", DISPATCH_QUEUE_SERIAL)
    private let gyroQueue = dispatch_queue_create("GyroscopeFileQueue", DISPATCH_QUEUE_SERIAL)
    private let orientationQueue = dispatch_queue_create("OrientationFileQueue", DISPATCH_QUEUE_SERIAL)
    private let emgQueue = dispatch_queue_create("EMGFileQueue", DISPATCH_QUEUE_SERIAL)

    // MARK: - Constructors

    override init() {
        super.init()
        setupNotifications()

        documentDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as? String
    }

    // MARK: - Instance Methods

    func beginRecording() {
        if documentDirectory == nil {
            println("No document directory to write to")
            return
        }
        recordingStartDate = NSDate()
        accelFileName = documentDirectory!.stringByAppendingPathComponent(recordingStartDate!.description + "-Acceleration.csv")
        gyroFileName = documentDirectory!.stringByAppendingPathComponent(recordingStartDate!.description + "-Gyroscope.csv")
        orientationFileName = documentDirectory!.stringByAppendingPathComponent(recordingStartDate!.description + "-Orientation.csv")
        emgFileName = documentDirectory!.stringByAppendingPathComponent(recordingStartDate!.description + "-EMG.csv")
        shouldRecord = true
    }

    func toggleRecording() {
        if shouldRecord {
            endRecording()
        } else {
            beginRecording()
        }
    }

    func endRecording() {
        shouldRecord = false
        recordingStartDate = nil
        accelFileName = nil
        gyroFileName = nil
        orientationFileName = nil
        emgFileName = nil
    }

    // MARK: - Private Instance Methods

    private func setupNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()

        notificationCenter.addObserverForName(TLMHubDidConnectDeviceNotification, object: nil, queue: nil) {
            (notification: NSNotification!) -> Void in
            myo?.setStreamEmg(TLMStreamEmgType.Enabled)
        }
        notificationCenter.addObserver(self, selector: Selector("onOrientation:"), name: TLMMyoDidReceiveOrientationEventNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("onAccelerometer:"), name: TLMMyoDidReceiveAccelerometerEventNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("onGyroscope:"), name: TLMMyoDidReceiveGyroscopeEventNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("onEmg:"), name: TLMMyoDidReceiveEmgEventNotification, object: nil)
    }

    private func writeToFile(filename: String, value: String, queue: dispatch_queue_t) {
        dispatch_async(queue) {

            let data: NSData! = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

            if NSFileManager.defaultManager().fileExistsAtPath(filename) {
                let handle: NSFileHandle! = NSFileHandle(forWritingAtPath: filename)
                handle.truncateFileAtOffset(handle!.seekToEndOfFile())
                handle.writeData(data)
            } else {
                data.writeToFile(filename, atomically: false)
            }
        }
    }

    // MARK: - Notification Handlers

    func onOrientation(notification: NSNotification!) {
        if let orientationEvent = notification.userInfo?[kTLMKeyOrientationEvent] as? TLMOrientationEvent {
            if shouldRecord {
                if let fileName = orientationFileName {
                    writeToFile(fileName, value: orientationEvent.toCSV(), queue: orientationQueue)
                }
            }
        }
    }

    func onAccelerometer(notification: NSNotification!) {
        if let accelerometerEvent = notification.userInfo?[kTLMKeyAccelerometerEvent] as? TLMAccelerometerEvent {

            // Apply a high pass filter to get rid of gravity
            let accelVector = accelerometerEvent.vector
            gravityVector = accelVector * highPassFilterAlpha + gravityVector * (1.0 - highPassFilterAlpha)

            if shouldRecord {
                if let fileName = accelFileName {
                    let linearVector = accelVector - gravityVector
                    writeToFile(fileName, value: accelerometerEvent.toCSV(linearVector), queue: accelQueue)
                }
            }
        }
    }

    func onGyroscope(notification: NSNotification!) {
        if let gyroscopeEvent = notification.userInfo?[kTLMKeyGyroscopeEvent] as? TLMGyroscopeEvent {
            if shouldRecord {
                if let fileName = gyroFileName {
                    writeToFile(fileName, value: gyroscopeEvent.toCSV(), queue: gyroQueue)
                }
            }
        }
    }

    func onEmg(notification: NSNotification!) {
        if let emgEvent = notification.userInfo?[kTLMKeyEMGEvent] as? TLMEmgEvent {
            if shouldRecord {
                if let fileName = emgFileName {
                    writeToFile(fileName, value: emgEvent.toCSV(), queue: emgQueue)
                }
            }
        }
    }
}
