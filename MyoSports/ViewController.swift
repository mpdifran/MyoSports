//
//  ViewController.swift
//  MyoSports
//
//  Created by Mark DiFranco on 2015-05-28.
//  Copyright (c) 2015 MDF Projects. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dataCollector = MyoDataCollector()

    private var myo: TLMMyo? {
        return TLMHub.sharedHub().myoDevices().first as? TLMMyo
    }

    @IBOutlet var myoStatusLabel: UILabel!
    @IBOutlet var recordingStateLabel: UILabel!
    @IBOutlet var recordingButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterface()
        setupNotifications()
    }

    // MARK: - Private Instance Methods

    private func setupNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()

        notificationCenter.addObserverForName(TLMHubDidConnectDeviceNotification, object: nil, queue: nil) {
            (notificaiton: NSNotification!) -> Void in
            self.updateInterface()
        }
        notificationCenter.addObserverForName(TLMHubDidDisconnectDeviceNotification, object: nil, queue: nil) {
            (notificaiton: NSNotification!) -> Void in
            self.updateInterface()
        }
    }

    private func updateInterface() {
        if myo != nil && myo!.state == TLMMyoConnectionState.Connected {
            myoStatusLabel.text = "Paired with " + myo!.name
            recordingButton.enabled = true
        } else {
            myoStatusLabel.text = "No Myo paired."
            recordingButton.enabled = false
        }

        if dataCollector.isRecording {
            recordingStateLabel.hidden = false
            recordingButton.setTitle("Stop Recording", forState: UIControlState.Normal)
        } else {
            recordingStateLabel.hidden = true
            recordingButton.setTitle("Start Recording", forState: UIControlState.Normal)
        }
    }

    // MARK: - IBAction Methods

    @IBAction func recordTapped(sender: UIButton) {
        dataCollector.toggleRecording()
        updateInterface()
    }
}
