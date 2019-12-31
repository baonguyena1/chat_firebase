//
//  ConversationViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/30/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxSwift

class ConversationViewController: UIViewController {

    @IBOutlet weak var converstionTableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let bag = DisposeBag()
    
    private let viewModel = ConversationViewModel()
    
    private var conversations = [Conversation]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.converstionTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialTableView()
        
        initialSearchController()
        
        initialLoginUser()
        
        initialReactive()
        
        observerConversation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SingleChatViewController {
            if let conversationId = sender as? String {
                destination.conversationId = conversationId
            }
        }
    }
    
    private func initialTableView() {
        converstionTableView.emptyDataSetSource = self
        converstionTableView.tableFooterView = UIView()
    }

    private func initialSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Localizable.kSearchConversations
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func initialLoginUser() {
        _ = LoginUserManager.shared
    }
    
    private func observerConversation() {
        guard let userId = FireBaseManager.shared.auth.currentUser?.uid else { return }
        viewModel.observeUserChatConversation(userId: userId)
    }
    
    private func initialReactive() {
        viewModel.conversations
            .subscribe(onNext: { [weak self] (conversations) in
                self?.conversations = conversations
            })
            .disposed(by: bag)
        
        converstionTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                guard let `self` = self else { return }
                let conversationId = self.conversations[indexPath.row].documentID
                self.performSegue(withIdentifier: Segue.kConversationToSingleChat, sender: conversationId)
            })
            .disposed(by: bag)
    }
}

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ConversationViewCell.self, at: indexPath)
        cell.conversation = conversations[indexPath.row]
        return cell
    }
}

extension ConversationViewController: DZNEmptyDataSetSource {
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

extension ConversationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
