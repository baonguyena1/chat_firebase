//
//  GroupMemberViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/7/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit

class GroupMemberViewController: UIViewController {

    @IBOutlet weak var memberTableView: UITableView!
    
    var members: [User]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberTableView.tableFooterView = UIView()
    }

}

extension GroupMemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: MemberViewCell.self, at: indexPath)
        let user = members[indexPath.row]
        cell.user = user
        return cell
    }
    
}
