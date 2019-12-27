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
    
    private var avatarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialTableView()
        
        initialLoginUser()
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
