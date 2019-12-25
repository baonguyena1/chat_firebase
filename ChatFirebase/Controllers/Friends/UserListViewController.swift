//
//  UserListViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/23/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxFirebase
import RxSwift

class UserListViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    
    private let bag = DisposeBag()
    
    private let viewModel = UserListViewModel()
    
    private var members = [Member]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.userTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialTableView()
        
        initialReactive()
        
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
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: MemberViewCell.self, at: indexPath)
        cell.member = members[indexPath.row]
        return cell
    }
}

extension UserListViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: ImageAsset.kPlaceholderMessageEmpty)!
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
