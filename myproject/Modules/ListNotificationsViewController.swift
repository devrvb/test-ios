//
//  ListNotificationsViewController.swift
//  isiclite-refactor
//
//  Created by Rafael Vilas Boas on 22/07/20.
//  Copyright © 2020 Intelbras S/A. All rights reserved.
//

import Foundation

@objc class NotificationWithDevice: NSObject {
    
    var deviceId: String
    var notification: Notification
    
    init(deviceId: String, notification: Notification) {
        self.deviceId = deviceId
        self.notification = notification
    }
}

class ListNotificationsViewController: BaseViewController, StoryboardLoadable {
        
    @IBOutlet weak var notificationsTableView: UITableView!
    private var notifications = [NotificationWithDevice]()
    private var backToPlayback = false
    @IBOutlet weak var noNotificationsTitleLabel: UILabel!
    @IBOutlet weak var noNotificationsDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        noNotificationsTitleLabel.isHidden = true
        noNotificationsDescriptionLabel.isHidden = true
        notificationsTableView.isHidden = true
        
        noNotificationsTitleLabel.text = "NO_NOTIFICATIONS_TITLE".localized()
        noNotificationsDescriptionLabel.text = "NO_NOTIFICATIONS_DESCRIPTION".localized()
        
        loadNotifications()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController != nil {
            setupNavBar()
        }
    }
    
    func setBackToPlayback(_ backToPlayback: Bool) {
        self.backToPlayback = backToPlayback
    }
    
    private func setupView() {
        let nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationsTableView.register(nib, forCellReuseIdentifier: "cell")

        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    private func setupNavBar() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "BACK".localized(), style: .plain, target: self, action: #selector(backButtonPressed))]
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
        self.navigationItem.title = "NOTIFICATIONS".localized()
        self.navigationItem.titleView?.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "icDots"), style: .done, target: self, action: #selector(onOverflowPressed))]
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc private func backButtonPressed(_ sender: UITapGestureRecognizer) {
        onBackPressed()
    }
    
    private func onRemoveNotifications() {
        showConfirmationDialog("REMOVE_NOTIFICATIONS_WARNING".localized(), withTitle: "WARNING".localized(), actionTitle: "REMOVE".localized(), callback: {
            VideoManager.shared.getDeviceModels().forEach { device in
                device.notifications.removeAll()
            }
            DatabaseManager.shared.save(needToSyncWithCloud: false)
            
            self.notifications.removeAll()
            
            DispatchQueue.main.async {
                self.notificationsTableView.reloadData()
                self.noNotificationsTitleLabel.isHidden = false
                self.noNotificationsDescriptionLabel.isHidden = false
                self.notificationsTableView.isHidden = true
            }
        })
    }
    
    @objc private func onOverflowPressed(_ sender: UITapGestureRecognizer) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        let deleteAction = UIAlertAction(title: "REMOVE_NOTIFICATIONS".localized().capitalized, style: .destructive, handler: { _ in
            self.onRemoveNotifications()
        })
        optionMenu.addAction(deleteAction)
                
        let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { _ in })
            optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: { })
    }
    
    private func onBackPressed() {
        
        if backToPlayback {
            
            let localUser = UserManager.shared.appUser
            if let lastVisualization = localUser.lastVisualization {
                let viewController = UIStoryboard.loadViewController() as PlaybackViewController
                viewController.initView(favorite: lastVisualization, isFromLastVisualization: true)
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                DashboardNavigationController.showMenu = true
                guard let window = UIApplication.shared.delegate?.window! else { return }
                window.backgroundColor = UIColor.white
                let nav1 = DashboardNavigationController()
                window.rootViewController = nav1
            }
            
        } else {
            DashboardNavigationController.showMenu = true
            guard let window = UIApplication.shared.delegate?.window! else { return }
            window.backgroundColor = UIColor.white
            let nav1 = DashboardNavigationController()
            window.rootViewController = nav1
        }
    }
    
    private func loadNotifications() {
        VideoManager.shared.getDeviceModels().forEach { device in
            device.notifications.forEach { notification in
                notifications.append(NotificationWithDevice(deviceId: device.getId(), notification: notification))
            }
        }
        
        notifications.sort { $0.notification.date > $1.notification.date }
        
        noNotificationsTitleLabel.isHidden = notifications.count > 0
        noNotificationsDescriptionLabel.isHidden = notifications.count > 0
        notificationsTableView.isHidden = notifications.count == 0
    }
    
}

extension ListNotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell
        cell.bind(notification: self.notifications[indexPath.row].notification)
        cell.selectionStyle = .none
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "notificationCell\(indexPath.row+1)"
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationWithDevice = self.notifications[indexPath.row]
        
        if notificationWithDevice.notification.type == .videoMotion || notificationWithDevice.notification.type == .videoLoss
            || notificationWithDevice.notification.type == .videoBlind {
            if let date = notificationWithDevice.notification.date.toDate(format: "yyyy-MM-dd HH:mm:ss") {
                let channel = ChannelPair(deviceId: notificationWithDevice.deviceId, channelId: notificationWithDevice.notification.channel)
                
                let viewController = UIStoryboard.loadViewController() as PlaybackViewController
                viewController.initView(channel: channel, playbackDate: date)
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE".localized(), handler: { _, indexPath  in
            self.notificationsTableView.beginUpdates()
            
            let notificationWithDevice = self.notifications[indexPath.row]
            let device = VideoManager.shared.getDeviceModel(notificationWithDevice.deviceId)
            let index: Int? = device?.notifications.firstIndex(of: notificationWithDevice.notification)
            if index != nil {
                device?.notifications.remove(at: index!)
                DatabaseManager.shared.save(needToSyncWithCloud: false)
            }
            
            self.notifications.remove(at: indexPath.row)
            self.notificationsTableView.deleteRows(at: [indexPath], with: .fade)
            self.notificationsTableView.endUpdates()
            
            if self.notifications.count == 0 {
                self.noNotificationsTitleLabel.isHidden = false
                self.noNotificationsDescriptionLabel.isHidden = false
                self.notificationsTableView.isHidden = true
            }
        })
        
        return [deleteAction]
    }
}
