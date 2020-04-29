//
//  Created by Zsombor Szabo on 26/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import UIKit
import CoreData
import os.log

class ExposureInfoTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    public var diagnosisServer: DiagnosisServer?
    
    private var fetchedResultsController: NSFetchedResultsController<ManagedExposureInfo>?
    
    var matchedKeyCountObservation: NSKeyValueObservation?
    
    @IBOutlet weak var exposureSummaryLabel: UILabel?
    @IBOutlet weak var matchedKeysSummaryLabel: UILabel?
    
    private func configureDaysSinceLastExposureObservationObserver() {
//        UserDefaults.standard.setValue(1, forKeyPath: UserDefaults.Key.matchedKeyCount)
        self.matchedKeyCountObservation = UserDefaults.standard.observe(\.matchedKeyCount, options: [.initial, .new], changeHandler: { [weak self] (_, change) in
            guard let self = self else { return }
            self.configureTableHeader()
        })
    }
    
    @IBOutlet var tableHeaderView: UIView?
    
    func configureTableHeader() {
        self.tableView.beginUpdates()
        if UserDefaults.standard.matchedKeyCount == 0 {
            self.tableView.tableHeaderView = nil
        }
        else {
            self.tableView.tableHeaderView = tableHeaderView
            self.exposureSummaryLabel?.text = String.init(format: NSLocalizedString("%d day(s) since last exposure", comment: ""), UserDefaults.standard.daysSinceLastExposure)
            self.matchedKeysSummaryLabel?.text = String.init(format: NSLocalizedString("Tap to see more exposures from %d matched key(s)", comment: ""), UserDefaults.standard.matchedKeyCount)
        }
        self.tableView.endUpdates()
    }
    
    @IBOutlet weak var toggleExposureNotificationBarButtonItem: UIBarButtonItem?
    
    public func configureToggleExposureNotificationBarButtonItem(animated: Bool = true) {
        ExposureNotificationManager.shared.getSettings { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                    case .failure(let error):
                        self.present(error as NSError, animated: animated)
                        return
                    case .success(let settings):
                        self.configureToggleExposureNotificationBarButtonItem(settings: settings, animated: animated)
                }
            }
        }
    }
    
    private func configureToggleExposureNotificationBarButtonItem(settings: ENSettings, animated: Bool = true) {
        self.toggleExposureNotificationBarButtonItem?.title = settings.enableState ? NSLocalizedString("Stop", comment: "") : NSLocalizedString("Start", comment: "")
    }
    
    @IBAction func handleTapToggleExposureNotificationBarButtonItem(_ sender: UIBarButtonItem) {
        ExposureNotificationManager.shared.getSettings { [weak self] (result) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                    case .failure(let error):
                        self.present(error as NSError, animated: true)
                        return
                    case .success(let settings):
                        let updatedSettings = ENMutableSettings(enableState: !settings.enableState)
                        ExposureNotificationManager.shared.changeSettings(updatedSettings) { [weak self] (result) in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
                                switch result {
                                    case .failure(let error):
                                        self.present(error as NSError, animated: true)
                                        return
                                    default:
                                        self.configureToggleExposureNotificationBarButtonItem(settings: updatedSettings, animated: true)
                                }
                            }
                    }
                }
            }
        }
    }
    
    @IBAction func handleTapExposureNotificationSummaryButton(_ sender: UIButton) {
        guard let session = ExposureNotificationManager.shared.currentExposureDetectionSession else { return }
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = [AddExposureInfosToCoreData(context: context, exposureDetectionSession: session)]
        
        operations.last?.completionBlock = {
            DispatchQueue.main.async {
                ExposureNotificationManager.shared.currentExposureDetectionSession = nil
                UserDefaults.shared.setValue(0, forKey: UserDefaults.Key.daysSinceLastExposure)
                UserDefaults.shared.setValue(0, forKey: UserDefaults.Key.matchedKeyCount)
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFetchedResultsController()
        self.configureToggleExposureNotificationBarButtonItem(animated: false)
        self.configureDaysSinceLastExposureObservationObserver()
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.navigationItem.prompt = NSLocalizedString("Your exposures with people positively diagnosed", comment: "")
    }
    
    @objc private func refresh(_ sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.performFetch(notifyUserOnError: true, completionHandler: { (result) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        })        
    }
    
    func initFetchedResultsController() {
        PersistentContainer.shared.load { error in
            do {
                if let error = error {
                    throw(error)
                }
                let managedObjectContext = PersistentContainer.shared.viewContext
                let request: NSFetchRequest<ManagedExposureInfo> = ManagedExposureInfo.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedExposureInfo.date, ascending: false)]
                request.returnsObjectsAsFaults = false
                request.fetchBatchSize = 200
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                self.fetchedResultsController?.delegate = self
                try self.fetchedResultsController?.performFetch()
                self.tableView.reloadData()
            }
            catch {
                os_log("Fetched results controller perform fetch failed=%@", log: .app, type: .error, error as CVarArg)
            }
        }
    }
    
    @IBAction func handleTapActionButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: NSLocalizedString("Upload positive diagnosis?", comment: ""), message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Permission Number", comment: "")
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            ()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Upload", comment: ""), style: .default, handler: { _ in
            
            let permissionNumber = alertController.textFields?.first?.text ?? ""
            
            ExposureNotificationManager.shared.getSelfExposureInfo { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                        case .failure(let error):
                            self.present(error as NSError, animated: true)
                            return
                        case .success(let selfExposureInfo):
                            let positiveDiagnosis = PositiveDiagnosis(keys: selfExposureInfo.keys, publicHealthAuthorityPermissionNumber: permissionNumber)
                            self.diagnosisServer?.upload(
                                positiveDiagnosis: positiveDiagnosis,
                                completion: { [weak self] (result) in
                                    DispatchQueue.main.async {
                                        guard let self = self else { return }
                                        switch result {
                                            case .failure(let error):
                                                self.present(error as NSError, animated: true)
                                                return
                                            case .success():
                                                () // TODO: Notify the user of success succintly
                                        }
                                    }
                            })
                    }
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    lazy var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .short
        return formatter
    }()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExposureInfoRow", for: indexPath)
        self.tableView(tableView, configure: cell, forRowAt: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, configure cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let exposureInfo = self.fetchedResultsController?.object(at: indexPath),
            let date = exposureInfo.date {
            
            var formattedString = [
                self.dateFormatter.string(from: date),
                self.durationFormatter.string(from: exposureInfo.duration) ?? ""
                ].joined(separator: " for ")
            formattedString += String(format: " at %d atten.", exposureInfo.attenuationValue)
            cell.textLabel?.text = formattedString
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                if let cell = self.tableView.cellForRow(at: indexPath!) {
                    self.tableView(self.tableView, configure: cell, forRowAt: indexPath!)
            }
            case .move:
                self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default: ()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}
