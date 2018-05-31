//
//  DiscoverTableViewController.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/26/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UITableViewController {
    
    //right corner profile pic
    private let rightBarProfilePic = UIImageView(image: UIImage(named: "default_profile_pic.png"))
    
    override func viewWillAppear(_ animated: Bool) {
        //Set navigation bar title
        navigationController?.navigationBar.prefersLargeTitles = true
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationItem.title = "Discover"
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    //MARK: functions related to right bar button pic---------------
    private func setupUI() {
        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(rightBarProfilePic)
        rightBarProfilePic.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        rightBarProfilePic.clipsToBounds = true
        rightBarProfilePic.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightBarProfilePic.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            rightBarProfilePic.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            rightBarProfilePic.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            rightBarProfilePic.widthAnchor.constraint(equalTo: rightBarProfilePic.heightAnchor)
            ])
        
        //Add action to rightBarProfilePic
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profilePicTapped))
        rightBarProfilePic.addGestureRecognizer(tap)
        rightBarProfilePic.isUserInteractionEnabled = true
    }
    
    //selector method for right bar profile pic
    @objc func profilePicTapped()
    {
        
        //self.performSegue(withIdentifier: "DiscoverToARMenu", sender: nil)
        
        //Decide current view controller and decide which segue to use
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
            if(vc is UINavigationController){
                vc = (vc as! UINavigationController).visibleViewController
            }
            
            if(vc is DiscoverTableViewController){
                print("At DiscoverTableViewController") //DEBUG
            } else if (vc is ARMenuViewController){
                print("At ARMenuViewController") //DEBUG //Not sure if it works yet
            }
        }
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        rightBarProfilePic.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    //resize right bar profile pic as the table scrolls up
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //1. Set up ButtonsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "buttonsCell", for: indexPath) as! ButtonsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //set up the button style
        cell.ARMenuButton.backgroundColor = FUREKA_Orange
        cell.ARMenuButton.tintColor = UIColor.white
        cell.ARMenuButton.layer.cornerRadius = 5
        
        //set up button delegate
        cell.delegate = self

        return cell
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }*/
 

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = " "
    }
    
}

extension DiscoverTableViewController {
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
        /// Image height/width for Landscape state
        static let ScaleForImageSizeForLandscape: CGFloat = 0.65
    }
}

extension DiscoverTableViewController : ButtonsTableViewCellDelegate {
    func ARMenuPressed() {
        self.performSegue(withIdentifier: "DiscoverToARMenu", sender: nil)
    }
    
    func SharePhotoPressed(){
        self.performSegue(withIdentifier: "DiscoverToSharePhoto", sender: nil)
    }
}
