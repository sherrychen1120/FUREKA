//
//  DiscoverViewController.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/24/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        //Set navigation bar title
        navigationController?.navigationBar.prefersLargeTitles = true
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationItem.title = "Discover"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    //--Buttons--
    @IBAction func ARMenuButton(_ sender: Any) {
        self.performSegue(withIdentifier: "DiscoverToARMenu", sender: nil)
    }
    
    //--Segues--
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = " "
        //navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
