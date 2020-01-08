//
//  AddPeopleViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/6/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxCocoa
import RxSwift

class AddPeopleViewController: UIViewController {
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var conversation: Conversation?
    
    private let bag = DisposeBag()
    
    private let viewModel = AddPeopleViewModel()
    
    private var addMembers = BehaviorRelay<Set<String>>(value: Set<String>())
    
    private var users = [User]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.userTableView.reloadData()
            }
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        initialTableView()
        
        initialReactive()
        
        initialSearchController()
        
        observeMembers()
    }
    
    private func initialTableView() {
        userTableView.emptyDataSetSource = self
        userTableView.tableFooterView = UIView()
    }
    
    private func observeMembers() {
        if let conversation = conversation {
            viewModel.observeMembers(without: conversation.activeMembers)
        }
    }
    
    private func initialReactive() {
        self.addMembers.bind(to: viewModel.addMembers).disposed(by: bag)
        
        viewModel.addButtonEnabled.bind(to: addButton.rx.isEnabled).disposed(by: bag)
        
        viewModel.addMembers
            .subscribe { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.userTableView.reloadData()
                }
            }
            .disposed(by: bag)
        
        viewModel.members
            .subscribe(onNext: { [weak self] (members) in
                self?.users = members
            })
            .disposed(by: bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.addMembersSuccess
            .subscribe { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: bag)
    }
    
    private func initialSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Localizable.kSearchFriends
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        if let conversation = conversation {
            viewModel.addMembersToConversation(members: Array(viewModel.addMembers.value), conversation: conversation.documentID)            
        }
    }
    
}

extension AddPeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: AddPeopleViewCell.self, at: indexPath)
        let user = users[indexPath.row]
        cell.user = user
        cell.addButton.setImage(viewModel.isMemberContains(user.documentID) ? ImageAssets.ic_check : ImageAssets.ic_uncheck, for: .normal)
        cell.addButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                self?.viewModel.addOrRemoveMember(user.documentID)
            }
            .disposed(by: cell.bag)
        return cell
    }
    
}

extension AddPeopleViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return ImageAssets.placeholder_message_empty!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26.0),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: Localizable.kNoMessages, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18.0),
            .foregroundColor: UIColor.lightGray,
            .paragraphStyle: paragraph
        ]
        return NSAttributedString(string: Localizable.kWhenYouHaveMessagesYoullSeeThemHere, attributes: attributes)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 30.0
    }
}

extension AddPeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
