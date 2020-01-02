//
//  FriendListViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/23/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxFirebase
import RxSwift

class FriendListViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    
    private let bag = DisposeBag()
    
    private let viewModel = UserListViewModel()
    
    private var members = [User]() {
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
        viewModel.observeMembers()
    }
    
    private func initialReactive() {
        viewModel.members
            .subscribe(onNext: { [weak self] (members) in
                self?.members = members
            })
            .disposed(by: bag)
        
        userTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                guard let `self` = self else { return }
                let friend = self.members[indexPath.row]
                self.performSegue(withIdentifier: Segue.kFriendToSingleChat, sender: friend)
            })
            .disposed(by: bag)
    }
    
    private func initialSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Localizable.kSearchFriends
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SingleChatViewController {
            if let friend = sender as? User {
                destination.chatAccession = .friend(friendId: friend.documentID)
            }
        }
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: MemberViewCell.self, at: indexPath)
        cell.member = members[indexPath.row]
        return cell
    }
}

extension FriendListViewController: DZNEmptyDataSetSource {
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

extension FriendListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
