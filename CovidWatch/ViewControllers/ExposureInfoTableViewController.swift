//
//  Created by Zsombor Szabo on 26/04/2020.
//

import UIKit
import CoreData
import os.log
import ExposureNotification

class ExposureInfoTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    public var diagnosisServer: DiagnosisServer?
    
    private var fetchedResultsController: NSFetchedResultsController<ManagedExposureInfo>?
    
    var matchedKeyCountObservation: NSKeyValueObservation?
    
    @IBOutlet weak var exposureSummaryLabel: UILabel?
    @IBOutlet weak var detailExposureSummaryLabel: UILabel?
    
    private func configureDaysSinceLastExposureObservationObserver() {
        self.matchedKeyCountObservation = UserDefaults.standard.observe(\.matchedKeyCount, options: [.initial, .new], changeHandler: { [weak self] (_, change) in
            self?.configureTableHeader()
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
            self.detailExposureSummaryLabel?.text = String.init(format: NSLocalizedString("Tap to see more exposures from %d matched key(s) with maximum risk score=%@", comment: ""), UserDefaults.standard.matchedKeyCount, UserDefaults.standard.maximumRiskScore)
        }
        self.tableView.endUpdates()
    }
    
    @IBOutlet weak var toggleExposureNotificationBarButtonItem: UIBarButtonItem?
    
    public func configureToggleExposureNotificationBarButtonItem(animated: Bool = true) {
        self.configureToggleExposureNotificationBarButtonItemEnabled(ENManager.shared.exposureNotificationEnabled)
    }
    
    func configureToggleExposureNotificationBarButtonItemEnabled(_ enabled: Bool) {
        self.toggleExposureNotificationBarButtonItem?.title = enabled ? NSLocalizedString("Stop", comment: "") : NSLocalizedString("Start", comment: "")
    }

    @IBAction func handleTapToggleExposureNotificationBarButtonItem(_ sender: UIBarButtonItem) {
        ENManager.shared.setExposureNotificationEnabled(!ENManager.shared.exposureNotificationEnabled) { [weak self] (error) in
            if let error = error {
                self?.present(error as NSError, animated: true)
                return
            }
            self?.configureToggleExposureNotificationBarButtonItemEnabled(ENManager.shared.exposureNotificationEnabled)
        }
    }
    
    @IBAction func handleTapResetExposureNotificationBarButtonItem(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: NSLocalizedString("Reset diagnosis keys and all data related to exposure notification?", comment: ""), message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            ()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .default, handler: { _ in
            ENManager.shared.resetAllData { (error) in
                if let error = error {
                    self.present(error as NSError, animated: true)
                    return
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func handleTapExposureNotificationSummaryButton(_ sender: UIButton) {
        guard let session = ENExposureDetectionSession.current else { return }

        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1

        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = [AddExposureInfosToCoreData(context: context, exposureDetectionSession: session)]

        operations.last?.completionBlock = {
            DispatchQueue.main.async {
                ENExposureDetectionSession.current = nil
                UserDefaults.shared.setValue(0, forKey: UserDefaults.Key.daysSinceLastExposure)
                UserDefaults.shared.setValue(0, forKey: UserDefaults.Key.matchedKeyCount)
                UserDefaults.shared.setValue(0, forKey: UserDefaults.Key.maximumRiskScore)
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
        (UIApplication.shared.delegate as? AppDelegate)?.performFetch(task: nil, completionHandler: { (result) in
            switch result {
                case .failure(let error):
                    self.present(error as NSError, animated: true)
                case .success(_): ()
            }
            self.refreshControl?.endRefreshing()
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
            
            ENManager.shared.getDiagnosisKeys { (keys, error) in
                if let error = error {
                    self.present(error as NSError, animated: true)
                    return
                }
                guard let keys = keys else { return }
                
                let positiveDiagnosis = PositiveDiagnosis(
                    keys: keys,
                    publicHealthAuthorityPermissionNumber: permissionNumber
                )
                self.diagnosisServer?.upload(
                    positiveDiagnosis: positiveDiagnosis,
                    completion: { [weak self] (result) in
                        
                        DispatchQueue.main.async {
                            switch result {
                                case .failure(let error):
                                    self?.present(error as NSError, animated: true)
                                    return
                                case .success(): ()
                                () // TODO: Notify the user of success succintly
                            }
                        }
                })
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
            formattedString += String(
                format: ", attenuation=%d, total risk score=%d, transmission risk level=%d",
                exposureInfo.attenuationValue,
                exposureInfo.totalRiskScore,
                exposureInfo.transmissionRiskLevel
            )
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
